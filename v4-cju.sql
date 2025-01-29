CREATE TABLE User
(
    id         SERIAL PRIMARY KEY,
    name       VARCHAR(100)        NOT NULL,
    email      VARCHAR(100) UNIQUE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE Category
(
    id   SERIAL PRIMARY KEY,
    name VARCHAR(100) UNIQUE NOT NULL
);

CREATE TABLE Product
(
    id          SERIAL PRIMARY KEY,
    name        VARCHAR(100)   NOT NULL,
    price       DECIMAL(10, 2) NOT NULL,
    category_id INT            NOT NULL,
    FOREIGN KEY (category_id) REFERENCES Category (id) ON DELETE CASCADE
);

CREATE TABLE Order
(
    id          SERIAL PRIMARY KEY,
    user_id     INT            NOT NULL,
    total_price DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    status      VARCHAR(50)             DEFAULT 'pending',
    created_at  TIMESTAMP               DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES User (id) ON DELETE CASCADE
);

CREATE TABLE OrderItem
(
    id         SERIAL PRIMARY KEY,
    order_id   INT            NOT NULL,
    product_id INT            NOT NULL,
    quantity   INT            NOT NULL CHECK (quantity > 0),
    price      DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (order_id) REFERENCES Order (id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES Product (id) ON DELETE CASCADE
);

WITH RecentOrders AS (SELECT o.id AS order_id, o.user_id, o.total_price, o.created_at
                      FROM "Order" o
                      WHERE o.created_at > NOW() - INTERVAL '30 days'
    )

SELECT u.id AS user_id, u.name, r.total_price, r.created_at, 'Recent Order' AS order_status
FROM RecentOrders r
         JOIN "User" u ON r.user_id = u.id

UNION ALL


SELECT u.id AS user_id, u.name, NULL AS total_price, NULL AS created_at, 'No Order' AS order_status
FROM "User" u
WHERE NOT EXISTS (SELECT 1
                  FROM "Order" o
                  WHERE o.user_id = u.id);

