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


INSERT INTO User (name, email)
SELECT 'User' || i, 'user' || i || '@example.com'
FROM generate_series(1, 200) AS i;


INSERT INTO Category (name)
SELECT 'Category' || i
FROM generate_series(1, 10) AS i;

INSERT INTO Product (name, price, category_id)
SELECT 'Product' || i,
       ROUND(RANDOM() * 900 + 100, 2),
       (SELECT id FROM Category ORDER BY RANDOM() LIMIT 1)
FROM generate_series(1, 50) AS i;

INSERT INTO Order (user_id, total_price, status)
SELECT (SELECT id FROM User ORDER BY RANDOM() LIMIT 1),
    0.00,
    CASE FLOOR(RANDOM() * 3)
        WHEN 0 THEN 'pending'
        WHEN 1 THEN 'completed'
        ELSE 'canceled'
END
FROM generate_series(1, 300);

INSERT INTO OrderItem (order_id, product_id, quantity, price)
SELECT (SELECT id FROM Order ORDER BY RANDOM() LIMIT 1),
    (SELECT id FROM Product ORDER BY RANDOM() LIMIT 1),
    FLOOR(RANDOM() * 5 + 1),
    (SELECT price FROM Product WHERE id = product_id)
FROM generate_series(1, 900);


UPDATE Order
SET total_price = (SELECT COALESCE(SUM(price * quantity), 0) FROM OrderItem WHERE OrderItem.order_id = Order.id);

