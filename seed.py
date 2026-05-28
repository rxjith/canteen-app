import psycopg2

def seed_canteen_database():
    try:
        # PostgreSQL Connection:
        connection = psycopg2.connect(
            dbname="canteen_db",
            user="canteen_admin",
            password="sjcetcanteen1$$$",
            host="127.0.0.1",
            port="5432"
        )
        
        cursor = connection.cursor()

        # Dynamic menu items representing the canteen ecosystem:
        dummy_menu = [
            ("Chicken Biriyani", 120.00, 45, True, "available"),
            ("Veg Fried Rice", 80.00, 30, False, "available"),
            ("Samosa", 15.00, 60, False, "available"),
            ("Masala Chai", 12.00, 150, False, "available"),
            ("Cold Coffee", 40.00, 0, False, "out_of_stock")
        ]

        # Clears out existing data so running this multiple times doesn't create duplicate entries:
        cursor.execute("TRUNCATE TABLE menu_items RESTART IDENTITY CASCADE;")

        insert_query = """
            INSERT INTO menu_items (name, price, current_stock, is_special, status)
            VALUES (%s, %s, %s, %s, %s);
        """
        
        cursor.executemany(insert_query, dummy_menu)
        connection.commit()
        print(f"🎉 Successfully seeded {len(dummy_menu)} items into the menu_items table!")

    except Exception as error:
        print(f"❌ Error while connecting to PostgreSQL: {error}")
        
    finally:
        if 'connection' in locals() and connection:
            cursor.close()
            connection.close()

if __name__ == "__main__":
    seed_canteen_database()