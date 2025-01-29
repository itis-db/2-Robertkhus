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

ALTER TABLE "OrderItem" DROP CONSTRAINT "orderitem_product_id_fkey";
ALTER TABLE "Order" DROP CONSTRAINT "order_user_id_fkey";


ALTER TABLE "Product" ADD COLUMN domain_key VARCHAR(200) UNIQUE;
UPDATE "Product" SET domain_key = name || '_' || category_id;


ALTER TABLE "User" ADD COLUMN domain_key VARCHAR(200) UNIQUE;
UPDATE "User" SET domain_key = email;

CREATE TABLE "Product_new" (
                               name        VARCHAR(100)   NOT NULL,
                               price       DECIMAL(10, 2) NOT NULL,
                               category_id INT            NOT NULL,
                               domain_key VARCHAR(200) UNIQUE,
                               FOREIGN KEY (category_id) REFERENCES "Category"(id) ON DELETE CASCADE,
                               PRIMARY KEY (domain_key)
);

INSERT INTO "Product_new" (name, price, category_id, domain_key)
SELECT name, price, category_id, domain_key FROM "Product";

DROP TABLE "Product";
ALTER TABLE "Product_new" RENAME TO "Product";

CREATE TABLE "User_new" (
                            name       VARCHAR(100)        NOT NULL,
                            email      VARCHAR(100) UNIQUE NOT NULL,
                            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                            domain_key VARCHAR(200) UNIQUE,
                            PRIMARY KEY (domain_key)
);

INSERT INTO "User_new" (name, email, created_at, domain_key)
SELECT name, email, created_at, domain_key FROM "User";


DROP TABLE "User";
ALTER TABLE "User_new" RENAME TO "User";


ALTER TABLE "OrderItem" ADD CONSTRAINT orderitem_product_domain_key_fkey FOREIGN KEY (product_id) REFERENCES "Product"(domain_key) ON DELETE CASCADE;
ALTER TABLE "Order" ADD CONSTRAINT order_user_domain_key_fkey FOREIGN KEY (user_id) REFERENCES "User"(domain_key) ON DELETE CASCADE;


ALTER TABLE "Product" DROP COLUMN id;
ALTER TABLE "User" DROP COLUMN id;


ALTER TABLE "Product" RENAME COLUMN domain_key TO id;
ALTER TABLE "User" RENAME COLUMN domain_key TO id;


COMMIT;

ROLLBACK;
