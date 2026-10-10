# ShopLite — Complete Full-Stack E-Commerce Application

ShopLite is a modern, production-grade, full-stack shopping application built with **Flutter (Material 3)** for Android/Web, **Node.js & Express.js** for RESTful API services, and **MySQL 8.0 (InnoDB)** for ACID-compliant transactional persistence.

---

## 📑 Architecture Overview

```
┌────────────────────────────────────────────────────────┐
│               Flutter Mobile / Web Client              │
│  (Material 3 • Provider • HTTP Client • Typed Models)  │
└───────────────────────────▲────────────────────────────┘
                            │ REST / JSON (HTTP)
                            ▼
┌────────────────────────────────────────────────────────┐
│                Express.js REST API Server              │
│  (CORS • Rate Limit • Parameterized SQL • Transactions)│
└───────────────────────────▲────────────────────────────┘
                            │ MySQL2 Pool / TCP 3306
                            ▼
┌────────────────────────────────────────────────────────┐
│                   MySQL 8.0 Database                   │
│   (shoplite_db • InnoDB • Row Locking FOR UPDATE)      │
└────────────────────────────────────────────────────────┘
```

### Key Engineering Highlights
- **End-to-End Integration:** The Flutter catalog renders data queried directly from MySQL via Express. The checkout flow creates verified order records and decrements stock transactionally.
- **Transactional Consistency & Deadlock Prevention:** Order placement runs inside MySQL transactions (`connection.beginTransaction()`). Product rows are locked in consistent ascending ID order (`SELECT ... FOR UPDATE`), preventing overselling under high concurrency.
- **Server-Authoritative Pricing:** Client-supplied totals are never trusted. The server recalculates line totals and grand totals using authoritative prices stored in the database.
- **Clean Architecture:** Strict separation between presentation, state management (Provider), repository abstraction, REST API controllers, business services, and database repositories.
- **Automated Email Notifications:** Once an order is successfully committed to MySQL, an email summary is dispatched via Nodemailer to the configured `ORDER_NOTIFICATION_EMAIL` with full customer details, ordered products, line totals, and grand total. Network or SMTP delivery errors are handled non-fatally and will never roll back or fail the placed order.

---

## 📂 Project Structure

```
shop_lite/
├── README.md                           # Master setup and architecture documentation
├── .gitignore                          # Root ignore for Flutter, Node, & secrets
├── frontend/                           # Flutter Material 3 application
│   ├── pubspec.yaml                    # Flutter dependencies (http, provider, intl)
│   ├── android/                        # Android wrapper with Internet permissions
│   ├── lib/
│   │   ├── main.dart                   # Application bootstrap
│   │   ├── app.dart                    # MultiProvider & MaterialApp setup
│   │   ├── core/
│   │   │   ├── config/app_config.dart  # Dynamic API base URL & platform detection
│   │   │   ├── errors/api_exception.dart # Centralized API domain exceptions
│   │   │   ├── network/api_client.dart # Centralized HTTP client with timeouts
│   │   │   └── theme/app_theme.dart    # Emerald green Material 3 theme palette
│   │   ├── models/
│   │   │   ├── product.dart            # Typed Product model with JSON parsing
│   │   │   ├── category.dart           # Category model
│   │   │   ├── cart_item.dart          # Cart line item model
│   │   │   └── order.dart              # Order & OrderItem models
│   │   ├── repositories/
│   │   │   ├── product_repository.dart # Product and category endpoints
│   │   │   └── order_repository.dart   # Order submission and query endpoints
│   │   ├── providers/
│   │   │   ├── cart_provider.dart      # Shared cart state with stock constraints
│   │   │   └── product_catalog_provider.dart # Catalog filter and search state
│   │   ├── screens/
│   │   │   ├── home_screen.dart        # Catalog grid, search bar, category chips
│   │   │   ├── product_details_screen.dart # Full details, stock, quantity selector
│   │   │   ├── cart_screen.dart        # Cart management, line totals, checkout nav
│   │   │   ├── checkout_screen.dart    # Demo customer form & transactional submission
│   │   │   ├── order_confirmation_screen.dart # Server ID, order summary
│   │   │   └── order_details_screen.dart # Live MySQL order verification
│   │   └── widgets/
│   │       ├── product_card.dart       # Responsive 2-column card with ratings
│   │       ├── category_filter.dart    # Horizontal category chips
│   │       ├── search_bar.dart         # Modern search input with clear button
│   │       ├── cart_badge.dart         # Real-time item count badge
│   │       ├── loading_view.dart       # Material 3 spinner
│   │       ├── error_view.dart         # Error presentation with retry action
│   │       └── empty_state.dart        # Illustrated empty filter/cart states
│   └── test/
│       ├── product_test.dart           # Model parsing & edge-case unit tests
│       ├── cart_provider_test.dart     # Cart math, stock caps, merging tests
│       ├── checkout_test.dart          # Payload mapping & cart retention tests
│       └── widget_test.dart            # Flutter widget launch smoke test
└── backend/                            # Express.js REST API
    ├── package.json                    # Node dependencies (express, mysql2, cors, dotenv)
    ├── .env.example                    # Template environment variables
    ├── .gitignore                      # Node modules & secret exclusions
    ├── database/
    │   ├── schema.sql                  # InnoDB schema (products, orders, order_items)
    │   └── seed.sql                    # Idempotent catalog data (16 products)
    ├── src/
    │   ├── server.js                   # Server entrypoint with 0.0.0.0 bind & shutdown
    │   ├── app.js                      # Express configuration, CORS, security headers
    │   ├── config/
    │   │   ├── env.js                  # Environment variable configuration
    │   │   └── database.js             # MySQL2 promise connection pool & health checks
    │   ├── controllers/
    │   │   ├── health_controller.js    # Health check handler
    │   │   ├── product_controller.js   # Products listing & detail handlers
    │   │   ├── category_controller.js  # Category list handler
    │   │   └── order_controller.js     # Transactional order placement & lookup
    │   ├── services/
    │   │   ├── product_service.js      # Product query business rules
    │   │   ├── category_service.js     # Category aggregations
    │   │   └── order_service.js        # Transaction orchestrator & stock validator
    │   ├── repositories/
    │   │   ├── product_repository.js   # Parameterized SQL & FOR UPDATE row locks
    │   │   ├── category_repository.js  # Grouped category queries
    │   │   └── order_repository.js     # Order & order item inserts and joins
    │   ├── middleware/
    │   │   ├── error_handler.js        # Centralized sanitized error handler
    │   │   └── request_logger.js       # Non-intrusive HTTP request logger
    │   └── validators/
    │       ├── product_query_validator.js # Query parameter sanitization
    │       └── order_validator.js      # Order payload format & type checks
    └── tests/
        ├── health.test.js              # Health endpoint unit tests
        ├── products.test.js            # Product search & filtering API tests
        └── orders.test.js              # Transaction & stock validation tests
```

---

## 🗄️ Database Design (`mini_shop`)

### 1. `products`
| Column | Type | Constraints | Description |
|---|---|---|---|
| `id` | INT | PRIMARY KEY, AUTO_INCREMENT | Unique product identifier |
| `name` | VARCHAR(255) | NOT NULL, INDEX | Product title |
| `description` | TEXT | NOT NULL | Detailed item description |
| `price` | DECIMAL(10,2) | NOT NULL, INDEX | Authoritative unit price |
| `category` | VARCHAR(100) | NOT NULL, INDEX | Product category |
| `image_url` | VARCHAR(500) | NOT NULL | High-resolution image link |
| `rating` | DECIMAL(3,2) | DEFAULT 0.00 | Average rating (0.0 to 5.0) |
| `stock_quantity` | INT | NOT NULL, DEFAULT 0 | Available inventory |
| `created_at` | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | Row creation time |
| `updated_at` | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP ON UPDATE | Last update timestamp |

### 2. `orders`
| Column | Type | Constraints | Description |
|---|---|---|---|
| `id` | INT | PRIMARY KEY, AUTO_INCREMENT | Generated order reference |
| `customer_name` | VARCHAR(150) | NOT NULL | Customer full name |
| `customer_phone` | VARCHAR(30) | NOT NULL | Customer contact number |
| `delivery_address` | TEXT | NOT NULL | Full delivery address |
| `total_amount` | DECIMAL(10,2) | NOT NULL | Server-calculated total |
| `status` | VARCHAR(50) | DEFAULT 'CONFIRMED', INDEX | Order processing status |
| `created_at` | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | Order timestamp |
| `updated_at` | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP ON UPDATE | Last update timestamp |

### 3. `order_items`
| Column | Type | Constraints | Description |
|---|---|---|---|
| `id` | INT | PRIMARY KEY, AUTO_INCREMENT | Line item reference |
| `order_id` | INT | FOREIGN KEY (`orders.id`) ON DELETE CASCADE | Parent order |
| `product_id` | INT | FOREIGN KEY (`products.id`) ON DELETE RESTRICT | Ordered product |
| `quantity` | INT | NOT NULL | Units purchased |
| `unit_price` | DECIMAL(10,2) | NOT NULL | Purchase-time unit price |
| `line_total` | DECIMAL(10,2) | NOT NULL | `quantity * unit_price` |
| `created_at` | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | Line creation time |

---

## 🚀 Setup & Execution Guide (Windows PowerShell)

Follow these step-by-step instructions in Windows PowerShell to set up and run ShopLite.

### Step 1: Clone or Navigate to the Workspace
```powershell
Set-Location -Path "C:\Users\himak\.gemini\antigravity\scratch\shop_lite"
```

### Step 2: Start the MySQL Service
Ensure the MySQL Windows Service is running:
```powershell
# Verify MySQL service status
Get-Service -Name *mysql*

# Start the service if not running
Start-Service -Name MySQL80
```

### Step 3: Create the Application Database & User
Connect to MySQL using your administrative CLI. You will be prompted for your MySQL root password:
```powershell
mysql -u root -p
```
Inside the MySQL shell, execute the following commands to create the dedicated database and grant permissions:
```sql
CREATE DATABASE IF NOT EXISTS shoplite_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Create application user if not exists
CREATE USER IF NOT EXISTS 'shoplite_user'@'localhost' IDENTIFIED BY 'shoplite_secure_password';
CREATE USER IF NOT EXISTS 'shoplite_user'@'%' IDENTIFIED BY 'shoplite_secure_password';

-- Grant permissions on shoplite_db
GRANT ALL PRIVILEGES ON shoplite_db.* TO 'shoplite_user'@'localhost';
GRANT ALL PRIVILEGES ON shoplite_db.* TO 'shoplite_user'@'%';
FLUSH PRIVILEGES;
EXIT;
```

### Step 4: Run the Schema & Seed Scripts
Execute the schema and idempotent sample catalog seed script:
```powershell
# Apply schema (creates products, orders, order_items)
Get-Content backend\database\schema.sql | mysql -u shoplite_user -pshoplite_secure_password shoplite_db

# Populate catalog data (16 sample products)
Get-Content backend\database\seed.sql | mysql -u shoplite_user -pshoplite_secure_password shoplite_db
```

### Step 5: Configure Backend Environment Variables
Create the local `.env` file from `.env.example`:
```powershell
Copy-Item backend\.env.example backend\.env
```
Ensure `backend\.env` contains:
```env
PORT=3000
NODE_ENV=development
DB_HOST=127.0.0.1
DB_PORT=3306
DB_NAME=shoplite_db
DB_USER=shoplite_user
DB_PASSWORD=shoplite_secure_password
DB_CONNECTION_LIMIT=10

# Nodemailer / SMTP Email Notification
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_SECURE=false
SMTP_USER=your_email@gmail.com
SMTP_PASS=your_app_password
SMTP_FROM="ShopLite Orders" <no-reply@shoplite.local>
ORDER_NOTIFICATION_EMAIL=admin@shoplite.com
```

### Step 6: Install Backend Dependencies & Run Tests
```powershell
Set-Location backend
npm install
npm test
Set-Location ..
```
*Expected test output:* 24 passed out of 24 tests across `health.test.js`, `products.test.js`, `orders.test.js`, and `email.test.js`.

### Step 7: Start the Node.js / Express API Server
```powershell
Set-Location backend
npm start
```
The server will bind to `0.0.0.0:3000`, making it accessible locally and over your LAN for Android devices.

---

## 🌐 API Verification & Smoke Testing

Open a new PowerShell window to verify API endpoints:

### 1. Health Endpoint
```powershell
Invoke-RestMethod -Uri "http://localhost:3000/api/health" -Method Get | ConvertTo-Json
```
**Response:**
```json
{
  "status": "healthy",
  "service": "shop-lite-backend",
  "timestamp": "2026-10-10T12:00:00.000Z",
  "database": {
    "status": "connected",
    "latencyMs": 2
  }
}
```

### 2. Products Endpoint (with Search & Category Filters)
```powershell
# Get all products
Invoke-RestMethod -Uri "http://localhost:3000/api/products" -Method Get

# Filter by category
Invoke-RestMethod -Uri "http://localhost:3000/api/products?category=Electronics" -Method Get

# Search by keyword
Invoke-RestMethod -Uri "http://localhost:3000/api/products?search=headphones" -Method Get
```

### 3. Categories Endpoint
```powershell
Invoke-RestMethod -Uri "http://localhost:3000/api/categories" -Method Get
```

### 4. Create Order Endpoint (`POST /api/orders`)
```powershell
$orderPayload = @{
  customer = @{
    name = "Demo Customer"
    phone = "+1 555-019-2834"
    address = "42 Silicon Boulevard, Tech City"
  }
  items = @(
    @{ productId = 1; quantity = 2 },
    @{ productId = 5; quantity = 1 }
  )
} | ConvertTo-Json

Invoke-RestMethod -Uri "http://localhost:3000/api/orders" -Method Post -Body $orderPayload -ContentType "application/json"
```

### 5. Retrieve Order Endpoint (`GET /api/orders/:id`)
```powershell
Invoke-RestMethod -Uri "http://localhost:3000/api/orders/1" -Method Get
```

---

## 📱 Running the Flutter Client

Open a new PowerShell window:
```powershell
Set-Location -Path "C:\Users\himak\.gemini\antigravity\scratch\shop_lite\frontend"
```

### Run Static Analysis and Automated Tests
```powershell
flutter analyze
flutter test
```
*Expected test output:* `All tests passed!` (15 tests passing, 0 issues found).

### Target A: Run in Google Chrome (Web)
```powershell
flutter run -d chrome
```
*Base URL used:* Automatically connects to `http://localhost:3000`.

### Target B: Run on Android Emulator
```powershell
flutter run -d emulator-5554
```
*Base URL used:* Automatically routes to `http://10.0.2.2:3000` (the Android emulator alias for host `localhost`).

### Target C: Run on a Physical Android Phone
1. Connect your Android phone to the same Wi-Fi network as your computer.
2. Find your computer's local network IP:
   ```powershell
   Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.InterfaceAlias -like "*Wi-Fi*" -or $_.InterfaceAlias -like "*Ethernet*" } | Select-Object IPAddress
   ```
   *(e.g., `192.168.1.50`)*
3. Ensure Windows Firewall permits incoming TCP traffic on port 3000:
   ```powershell
   # Run in an elevated PowerShell terminal
   New-NetFirewallRule -DisplayName "ShopLite Backend Port 3000" -Direction Inbound -LocalPort 3000 -Protocol TCP -Action Allow
   ```
4. Run Flutter targeting your connected physical device:
   ```powershell
   flutter run -d <DEVICE_ID> --dart-define=API_URL=http://<YOUR_LAN_IP>:3000
   ```
   *Alternative:* You can also tap the **Settings icon** in the ShopLite top AppBar inside the app at any time to dynamically change or paste your computer's LAN IP address without recompiling!

---

## 🔒 Security & Best Practices
- **No Credentials in Frontend:** Database credentials never enter Flutter code. All database queries are routed through the Express API layer.
- **SQL Injection Prevention:** 100% of queries use MySQL2 prepared statements with parameterized placeholders (`?`).
- **Environment Isolation:** Secrets are kept in local `.env` and omitted from version control via `.gitignore`.
- **Sanitized Errors:** In production mode, database exceptions return standardized error codes and client-safe messages without leaking schema names, table structures, or system stack traces.
