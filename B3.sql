create database  session06_b3;

create table users(
id int primary key auto_increment,
name varchar(100),
myMoney double,
address varchar(255),
phone varchar(11),
dateOfBirth date,
status bit
);

create table transfer(
sender_id int ,
receiver_id int,
money double,
transfer_date datetime,

primary key (sender_id, receiver_id),
foreign key (sender_id) references users(id),
foreign key (receiver_id) references users(id)
);

INSERT INTO users (name, myMoney, address, phone, dateOfBirth, status) VALUES
('Nguyễn Văn A', 15000000.00, '123 Đường Láng, Hà Nội', '0912345678', '1985-05-20', 1),
('Trần Thị B', 20000000.00, '456 Đường Giải Phóng, Hà Nội', '0923456789', '1990-08-15', 1),
('Lê Minh C', 30000000.00, '789 Đường Nguyễn Trãi, Hà Nội', '0934567890', '1988-12-25', 1),
('Phạm Thanh D', 25000000.00, '101 Đường Cầu Giấy, Hà Nội', '0945678901', '1992-03-10', 1),
('Hoàng Thị E', 35000000.00, '202 Đường Kim Mã, Hà Nội', '0956789012', '1987-07-30', 1);

INSERT INTO transfer (sender_id, receiver_id, money, transfer_date) VALUES
(1, 2, 5000000.00, '2024-07-10 10:00:00'),
(2, 3, 3000000.00, '2024-07-11 11:30:00'),
(3, 4, 7000000.00, '2024-07-12 14:00:00'),
(4, 5, 2000000.00, '2024-07-13 16:45:00'),
(5, 1, 6000000.00, '2024-07-14 09:15:00');




DELIMITER //

CREATE PROCEDURE TransferMoney(
    IN sender_id INT,
    IN receiver_id INT,
    IN amount DOUBLE
)
BEGIN
    DECLARE sender_balance DOUBLE;

    -- Start the transaction
    START TRANSACTION;

    -- Get the sender's current balance
    SELECT myMoney INTO sender_balance FROM users WHERE id = sender_id FOR UPDATE;

    -- Check if the sender has enough balance
    IF sender_balance < amount THEN
        -- Rollback the transaction if not enough balance
        ROLLBACK;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Out of balance';
    ELSE
        -- Deduct the amount from sender
        UPDATE users SET myMoney = myMoney - amount WHERE id = sender_id;

        -- Add the amount to receiver
        UPDATE users SET myMoney = myMoney + amount WHERE id = receiver_id;

        -- Insert the transfer record
        INSERT INTO transfer (sender_id, receiver_id, money, transfer_date) 
        VALUES (sender_id, receiver_id, amount, NOW());

        -- Commit the transaction
        COMMIT;
    END IF;
END //

DELIMITER ;


CALL TransferMoney(1, 2, 50000000.00);