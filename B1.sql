create database trigger_quan_ly_user_products;
use trigger_quan_ly_user_products;
create table users(
id int primary key auto_increment,
name varchar(100),
address varchar(255),
phone varchar(11),
dateOfBirth date,
status bit
);

create table products(
id int primary key auto_increment,
name varchar(100),
price double,
stock int,
status bit
);

create table shopping_cart(
id int auto_increment,
user_id int,
product_id int,
quantity int,
amount double,

primary key (id,user_id,product_id),
foreign key (user_id) references users(id),
foreign key (product_id) references products(id)
);

-- Insert sample data into users table
INSERT INTO users (name, address, phone, dateOfBirth, status) VALUES
('Nguyen Van A', '123 Le Loi, Ha Noi', '0901234567', '1990-01-01', 1),
('Tran Thi B', '456 Tran Phu, Ho Chi Minh', '0912345678', '1985-05-15', 1),
('Le Van C', '789 Nguyen Trai, Da Nang', '0923456789', '1992-10-20', 1),
('Pham Thi D', '101 Ngo Quyen, Hai Phong', '0934567890', '1988-07-07', 1),
('Hoang Van E', '202 Ly Thuong Kiet, Can Tho', '0945678901', '1995-12-12', 1);

-- Insert sample data into products table
INSERT INTO products (name, price, stock, status) VALUES
('Banana', 15000.0, 100, 1),
('Apple', 25000.0, 50, 1),
('Orange', 20000.0, 70, 1),
('Mango', 30000.0, 30, 1),
('Grapes', 40000.0, 20, 1);

-- Insert sample data into shopping_cart table
INSERT INTO shopping_cart (user_id, product_id, quantity, amount) VALUES
(1, 1, 2, 30000.0),
(2, 3, 1, 20000.0),
(3, 2, 5, 125000.0),
(4, 4, 3, 90000.0),
(5, 5, 1, 40000.0);


-- using trigger to update amout when price of price change
DELIMITER //

CREATE TRIGGER update_amount_on_price_change
AFTER UPDATE ON products
FOR EACH ROW
BEGIN
    IF OLD.price != NEW.price THEN
        UPDATE shopping_cart 
        SET amount = NEW.price * quantity 
        WHERE product_id = NEW.id;
    END IF;
END //

DELIMITER ;

-- using trigger to delete data in shopping cart when product is deleted
delimiter //
create trigger delete_cart_items_on_product_delete
before delete on products
for each row
begin
delete from shopping_cart where product_id = old.id;
end //
delimiter ;

select * from products;
select * from shopping_cart;


delete from products where id =5;

-- add product to cart

-- before insert to cart. check new quantity > stock
DELIMITER //

CREATE TRIGGER check_stock_before_insert
BEFORE INSERT ON shopping_cart
FOR EACH ROW
BEGIN
    DECLARE current_stock INT;

    -- Lấy số lượng tồn kho hiện tại của sản phẩm
    SELECT stock INTO current_stock FROM products WHERE id = NEW.product_id;

    -- Kiểm tra nếu số lượng yêu cầu lớn hơn số lượng tồn kho
    IF NEW.quantity > current_stock THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Not enough stock to add to cart';
    END IF;
    
    update products 
	set stock = stock - new.quantity
	where id = new.product_id;
END //

DELIMITER ;



select * from products;
select * from shopping_cart;

drop trigger update_amount_on_price_change;

-- Thêm sản phẩm vào giỏ hàng với số lượng hợp lệ
INSERT INTO shopping_cart (user_id, product_id, quantity, amount) VALUES (1, 4, 31, 30000.0);

-- Thêm sản phẩm vào giỏ hàng với số lượng vượt quá số lượng tồn kho
INSERT INTO shopping_cart (user_id, product_id, quantity, amount) VALUES (2, 1, 200, 3000000.0);