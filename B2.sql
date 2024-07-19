-- Tạo thủ tục thêm sản phẩm vào giỏ hàng với giao dịch
DELIMITER //
CREATE PROCEDURE add_to_cart(IN p_user_id INT, IN p_product_id INT, IN p_quantity INT)
BEGIN
    DECLARE current_stock INT;
    DECLARE product_price DOUBLE;

    -- Bắt đầu giao dịch
    START TRANSACTION;

    -- Lấy số lượng tồn kho hiện tại và giá của sản phẩm
    SELECT stock, price INTO current_stock, product_price FROM products WHERE id = p_product_id;

    -- Kiểm tra nếu số lượng yêu cầu lớn hơn số lượng tồn kho
    IF p_quantity > current_stock THEN
        -- Rollback giao dịch nếu không đủ hàng
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Not enough stock to add to cart';
        ROLLBACK;
    ELSE
        -- Thêm sản phẩm vào giỏ hàng
        INSERT INTO shopping_cart (user_id, product_id, quantity, amount) 
        VALUES (p_user_id, p_product_id, p_quantity, p_quantity * product_price);
        
        -- Trừ số lượng tồn kho của sản phẩm
        UPDATE products 
        SET stock = stock - p_quantity 
        WHERE id = p_product_id;
        
        -- Commit giao dịch
        COMMIT;
    END IF;
END //
DELIMITER ;

-- Tạo thủ tục xóa sản phẩm khỏi giỏ hàng với giao dịch
DELIMITER //
CREATE PROCEDURE remove_from_cart(IN p_cart_id INT, IN p_user_id INT, IN p_product_id INT)
BEGIN
    DECLARE cart_quantity INT;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION 
    BEGIN
        -- Rollback transaction if any error occurs
        ROLLBACK;
    END;

    -- Bắt đầu giao dịch
    START TRANSACTION;

    -- Lấy số lượng của sản phẩm trong giỏ hàng
    SELECT quantity INTO cart_quantity FROM shopping_cart 
    WHERE id = p_cart_id AND user_id = p_user_id AND product_id = p_product_id;

    -- Kiểm tra nếu sản phẩm có tồn tại trong giỏ hàng
    IF cart_quantity IS NOT NULL THEN
        -- Xóa sản phẩm khỏi giỏ hàng
        DELETE FROM shopping_cart WHERE id = p_cart_id AND user_id = p_user_id AND product_id = p_product_id;

        -- Trả lại số lượng sản phẩm vào kho
        UPDATE products 
        SET stock = stock + cart_quantity 
        WHERE id = p_product_id;

        -- Commit giao dịch
        COMMIT;
    ELSE
        -- Rollback giao dịch nếu không tìm thấy sản phẩm trong giỏ hàng
        ROLLBACK;
    END IF;
END //
DELIMITER ;

-- kiểm tra
-- Thêm sản phẩm vào giỏ hàng với số lượng hợp lệ
CALL add_to_cart(1, 1, 2);

-- Thêm sản phẩm vào giỏ hàng với số lượng vượt quá số lượng tồn kho
CALL add_to_cart(2, 1, 200);

-- Xóa sản phẩm khỏi giỏ hàng và trả lại số lượng vào kho
CALL remove_from_cart(9, 1, 1);


SELECT * FROM shopping_cart;
SELECT * FROM products;