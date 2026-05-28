from fastapi import FastAPI, HTTPException, Depends
from pydantic import BaseModel
import asyncpg
import asyncio
from datetime import datetime, timedelta
import urllib.parse
from contextlib import asynccontextmanager

# Database connection configuration
DB_CONFIG = {
    "database": "canteen_db",
    "user": "canteen_admin",
    "password": "sjcetcanteen1$$$",  # <-- Keep your real password here
    "host": "127.0.0.1",
    "port": "5432"
}

# --- THE JANITOR BACKGROUND WORKER ---
async def order_janitor():
    """Loops infinitely every 30 seconds to free up stock from unpaid, expired orders."""
    while True:
        try:
            conn = await asyncpg.connect(**DB_CONFIG)
            async with conn.transaction():
                # 1. Find all orders that are pending and past their expiration time
                expired_orders = await conn.fetch(
                    "SELECT order_id FROM orders WHERE status = 'pending_payment' AND expires_at < $1 FOR UPDATE",
                    datetime.now()
                )

                if expired_orders:
                    for record in expired_orders:
                        o_id = record['order_id']
                        
                        # 2. Return stock for each item in the expired order
                        items = await conn.fetch(
                            "SELECT item_id, quantity FROM order_items WHERE order_id = $1", o_id
                        )
                        for item in items:
                            await conn.execute(
                                "UPDATE menu_items SET current_stock = current_stock + $1 WHERE item_id = $2",
                                item['quantity'], item['item_id']
                            )
                        
                        # 3. Mark the order itself as expired
                        await conn.execute(
                            "UPDATE orders SET status = 'expired' WHERE order_id = $1", o_id
                        )
                    print(f"🧹 Janitor: Cleaned up and released stock for {len(expired_orders)} expired orders.")
            await conn.close()
        except Exception as e:
            print(f"❌ Janitor Error: {e}")
        
        # Wait 30 seconds before checking again
        await asyncio.sleep(30)

# Manage the server lifetime events
@asynccontextmanager
async def lifespan(app: FastAPI):
    # This runs when the server starts up
    janitor_task = asyncio.create_task(order_janitor())
    yield
    # This runs when the server shuts down
    janitor_task.cancel()

app = FastAPI(title="Campus Canteen Warzone Engine", lifespan=lifespan)

# Helper to manage async database connections
async def get_db():
    conn = await asyncpg.connect(**DB_CONFIG)
    try:
        yield conn
    finally:
        await conn.close()

# Data validation models
class CartItem(BaseModel):
    item_id: int
    quantity: int

class CheckoutRequest(BaseModel):
    user_id: str
    cart: list[CartItem]

@app.post("/api/checkout")
async def checkout(request: CheckoutRequest, conn=Depends(get_db)):
    async with conn.transaction():
        total_amount = 0.0
        order_items_to_create = []

        for cart_item in request.cart:
            item = await conn.fetchrow(
                "SELECT name, price, current_stock FROM menu_items WHERE item_id = $1 FOR UPDATE",
                cart_item.item_id
            )

            if not item:
                raise HTTPException(status_code=404, detail=f"Item ID {cart_item.item_id} not found")

            if item['current_stock'] < cart_item.quantity:
                raise HTTPException(
                    status_code=400, 
                    detail=f"Warzone Alert! Not enough {item['name']} left. Only {item['current_stock']} remaining."
                )

            item_total = float(item['price']) * cart_item.quantity
            total_amount += item_total
            order_items_to_create.append((cart_item.item_id, cart_item.quantity))

            await conn.execute(
                "UPDATE menu_items SET current_stock = current_stock - $1 WHERE item_id = $2",
                cart_item.quantity, cart_item.item_id
            )

        created_at = datetime.now()
        expires_at = created_at + timedelta(minutes=5)

        order_id = await conn.fetchval(
            """
            INSERT INTO orders (user_id, total_amount, status, created_at, expires_at)
            VALUES ($1, $2, 'pending_payment', $3, $4) RETURNING order_id
            """,
            request.user_id, total_amount, created_at, expires_at
        )

        for item_id, qty in order_items_to_create:
            await conn.execute(
                "INSERT INTO order_items (order_id, item_id, quantity) VALUES ($1, $2, $3)",
                order_id, item_id, qty
            )

        canteen_upi = "canteen@upi"
        payee_name = "Campus Canteen"
        transaction_note = f"Order-{order_id}"
        
        upi_params = {
            "pa": canteen_upi, "pn": payee_name, "am": f"{total_amount:.2f}",
            "tr": str(order_id), "tn": transaction_note, "cu": "INR"
        }
        
        upi_url = f"upi://pay?{urllib.parse.urlencode(upi_params)}"

        return {
            "status": "success",
            "message": "Stock locked for 5 minutes. Proceed to payment.",
            "order_id": order_id,
            "total_amount": total_amount,
            "upi_url": upi_url
        }
        
class VerifyOrderRequest(BaseModel):
    order_id: int

@app.post("/api/admin/verify")
async def verify_and_complete_order(request: VerifyOrderRequest, conn=Depends(get_db)):
    async with conn.transaction():
        # 1. Fetch the order and lock it for status updates
        order = await conn.fetchrow(
            "SELECT status, total_amount FROM orders WHERE order_id = $1 FOR UPDATE",
            request.order_id
        )

        if not order:
            raise HTTPException(status_code=404, detail=f"Order #{request.order_id} not found.")

        # 2. Check current status safety rules
        if order['status'] == 'completed':
            raise HTTPException(status_code=400, detail="Security Alert: This food token has ALREADY been claimed!")
        
        if order['status'] == 'expired':
            raise HTTPException(status_code=400, detail="Order Expired! Stock was already released back to inventory.")

        # 3. Fetch the actual food items inside this order so staff knows what to hand over
        items = await conn.fetch(
            """
            SELECT m.name, oi.quantity 
            FROM order_items oi
            JOIN menu_items m ON oi.item_id = m.item_id
            WHERE oi.order_id = $1
            """,
            request.order_id
        )

        # Format items into a friendly list for the staff UI dashboard
        item_list = [{"name": item['name'], "quantity": item['quantity']} for item in items]

        # 4. Officially complete the order
        await conn.execute(
            "UPDATE orders SET status = 'completed' WHERE order_id = $1",
            request.order_id
        )

        return {
            "status": "verified",
            "message": "Payment verified. Hand over food!",
            "order_details": {
                "order_id": request.order_id,
                "total_amount": float(order['total_amount']),
                "items": item_list
            }
        }