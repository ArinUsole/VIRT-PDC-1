CREATE TABLE IF NOT EXISTS orders
(
    id SERIAL PRIMARY KEY,
    descr TEXT,
    price INTEGER
);
COMMENT ON TABLE orders IS 'Заказы';
COMMENT ON COLUMN orders.descr IS 'наименование';
COMMENT ON COLUMN orders.price IS 'цена';
CREATE TABLE IF NOT EXISTS clients(  
    id SERIAL NOT NULL PRIMARY KEY,
    fullName TEXT,
    country TEXT,
    idOrder INTEGER REFERENCES orders
);
CREATE INDEX IF NOT EXISTS index_clients_1 ON clients (country);
COMMENT ON TABLE clients IS 'Клиенты';
COMMENT ON COLUMN clients.fullName IS 'фамилия';
COMMENT ON COLUMN clients.fullName IS 'страна проживания';
COMMENT ON COLUMN clients.fullName IS 'заказ';