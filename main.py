from fastapi import FastAPI, HTTPException, Depends
from pydantic import BaseModel
import asyncpg
from datetime import datetime, timedelta
import urllib.parse

app = FastAPI(title="Campus Canteen Warzone Engine")

# Database connection configuration
DB_CONFIG = {
    "database": "canteen_db",
    "user": "canteen_admin",
    "password": "sjcetcanteen1$$$",
    "host": "127.0.0.1",
    "port": "5432"
}

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
    user_id: str  # In production, this comes from auth/session
    cart: list[CartItem]

@app.post("/api/checkout")
async def checkout(request: CheckoutRequest, conn=Depends(get_db)):
    # Start a formal SQL transaction block
    async with conn.transaction():
        total_amount = 0.0
        order_items_to_create = []

        # 1. Loop through cart items and check/lock stock atomically
        for cart_item in request.cart:
            # SELECT ... FOR UPDATE locks the row so no other request can modify it mid-calculation
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

            # Calculate prices
            item_total = float(item['price']) * cart_item.quantity
            total_amount += item_total

            # Track for bulk insertion later
            order_items_to_create.append((cart_item.item_id, cart_item.quantity))

            # Deduct the stock immediately to reserve it for this student
            await conn.execute(
                "UPDATE menu_items SET current_stock = current_stock - $1 WHERE item_id = $2",
                cart_item.quantity, cart_item.item_id
            )

        # 2. Create the Order Record with a 5-minute expiration window
        created_at = datetime.now()
        expires_at = created_at + timedelta(minutes=5)

        order_id = await conn.fetchval(
            """
            INSERT INTO orders (user_id, total_amount, status, created_at, expires_at)
            VALUES ($1, $2, 'pending_payment', $3, $4) RETURNING order_id
            """,
            request.user_id, total_amount, created_at, expires_at
        )

        # 3. Insert the individual items into the order_items bridge table
        for item_id, qty in order_items_to_create:
            await conn.execute(
                "INSERT INTO order_items (order_id, item_id, quantity) VALUES ($1, $2, $3)",
                order_id, item_id, qty
            )

        # 4. Generate the Dynamic UPI Deep Link
        canteen_upi = "canteen@upi"  # Replace with actual canteen VPA
        payee_name = "Campus Canteen"
        transaction_note = f"Order-{order_id}"
        
        upi_params = {
            "pa": canteen_upi,
            "pn": payee_name,
            "am": f"{total_amount:.2f}",
            "tr": str(order_id),
            "tn": transaction_note,
            "cu": "INR"
        }
        
        # URL encode the parameters to ensure it works perfectly on mobile browsers
        upi_url = f"upi://pay?{urllib.parse.urlencode(upi_params)}"

        return {
            "status": "success",
            "message": "Stock locked for 5 minutes. Proceed to payment.",
            "order_id": order_id,
            "total_amount": total_amount,
            "upi_url": upi_url
        }