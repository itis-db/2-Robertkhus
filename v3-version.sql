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


BEGIN;


ALTER TABLE User ALTER COLUMN name TYPE TEXT;
ALTER TABLE Product ALTER COLUMN price TYPE NUMERIC(12,2);


ALTER TABLE User ADD COLUMN phone VARCHAR(20);
ALTER TABLE Order ADD COLUMN updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP;


ALTER TABLE User ADD CONSTRAINT unique_phone UNIQUE (phone);
ALTER TABLE Product ADD CONSTRAINT positive_price CHECK (price > 0);
ALTER TABLE OrderItem ADD CONSTRAINT positive_quantity CHECK (quantity > 0);


ROLLBACK;
