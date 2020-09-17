CREATE DATABASE hotel_reservation;

USE hotel_reservation;

CREATE TABLE hotel_reservation.user(
	id VARCHAR(40) NOT NULL PRIMARY KEY,
    username VARCHAR(30) NOT NULL UNIQUE,
    email VARCHAR(120) NOT NULL UNIQUE,
    profile_picture VARCHAR(20) NOT NULL DEFAULT 'default.png',
    password VARCHAR(200) NOT NULL,
    role VARCHAR(15)
);

CREATE TABLE hotel_reservation.room(
	id VARCHAR(40) NOT NULL PRIMARY KEY,
    type VARCHAR(10) NOT NULL UNIQUE,
    quantity INT NOT NULL
);

CREATE TABLE hotel_reservation.reservation(
	id VARCHAR(40) NOT NULL PRIMARY KEY,
    client_name VARCHAR(40) NOT NULL,
    email VARCHAR(120) NOT NULL UNIQUE,
    national_id INT NOT NULL UNIQUE,
    adults INT NOT NULL,
    children INT NOT NULL,
    checkin_date DATE NOT NULL,
    checkout_date DATE NOT NULL,
    gender VARCHAR(10) NOT NULL,
    birthdate DATE NOT NULL,
    date_posted DATETIME NOT NULL,
    user_username VARCHAR(30) NOT NULL,
    room_type VARCHAR(10) NOT NULL,
    CONSTRAINT FK_reservation_username FOREIGN KEY (user_username) REFERENCES user(username) ON UPDATE CASCADE,
    CONSTRAINT FK_reservation_room_type FOREIGN KEY (room_type) REFERENCES room(type) ON UPDATE CASCADE,
    CHECK (adults <= 3),
    CHECK (children <= 2)
);


#TRIGGERS FOR INCREASING AND DECREASING THE QUANTITY OF ROOMS WHEN INSERTING / UPDATING OR DELETING A ROW FROM RESERVATION TABLE
DELIMITER $$
CREATE TRIGGER decrease_room_quantity_on_insert BEFORE INSERT
ON hotel_reservation.reservation
FOR EACH ROW BEGIN
	DECLARE resultQuantity INT;

	SELECT quantity FROM hotel_reservation.room WHERE type = NEW.room_type INTO resultQuantity; 

	IF resultQuantity != 0 THEN
		UPDATE hotel_reservation.room SET quantity= quantity - 1 WHERE type = NEW.room_type;
	ELSE
		signal sqlstate '45000' SET MESSAGE_TEXT = "No Free Room available! INTENSIONAL CUSTOM ERROR";
	END IF;
END$$
DELIMITER ;


DELIMITER $$
CREATE TRIGGER decrease_room_quantity_on_update BEFORE UPDATE
ON hotel_reservation.reservation
FOR EACH ROW
BEGIN
	DECLARE resultQuantity INT;
    DECLARE oldResultQuantity INT;
	IF OLD.room_type != NEW.room_type THEN
		SELECT quantity FROM hotel_reservation.room WHERE type = NEW.room_type INTO resultQuantity;
        SELECT quantity FROM hotel_reservation.room WHERE type = OLD.room_type INTO oldResultQuantity; 

		IF resultQuantity != 0 THEN
			UPDATE hotel_reservation.room SET quantity= quantity - 1 WHERE type = NEW.room_type;
            UPDATE hotel_reservation.room SET quantity= quantity + 1 WHERE type = OLD.room_type;
		ELSE
			signal sqlstate '45000' SET MESSAGE_TEXT = "No Free Room available! INTENSIONAL CUSTOM ERROR";
		END IF;
	END IF;
END$$
DELIMITER ;


DELIMITER $$
CREATE TRIGGER increase_room_quantity_on_delete AFTER DELETE
ON hotel_reservation.reservation
FOR EACH ROW BEGIN
	UPDATE hotel_reservation.room SET quantity= quantity + 1 WHERE type = OLD.room_type;
END$$
DELIMITER ;


# DESCRBIE TABLES
DESCRIBE hotel_reservation.reservation;
DESCRIBE hotel_reservation.user;
DESCRIBE hotel_reservation.room;


# INSERT DATA 
INSERT INTO hotel_reservation.room VALUES(UUID(), "suite", 5);
INSERT INTO hotel_reservation.room VALUES(UUID(), "family", 6);
INSERT INTO hotel_reservation.room VALUES(UUID(), "deluxe", 4);
INSERT INTO hotel_reservation.room VALUES(UUID(), "classic", 4);
INSERT INTO hotel_reservation.room VALUES(UUID(), "superior", 3);
INSERT INTO hotel_reservation.room VALUES(UUID(), "luxury", 1);
INSERT INTO hotel_reservation.user(id, username, email, password, role) VALUES(UUID(), "Alexander", "alexpie@gmail.com", "sndosdnivsfjdvfsdkvfdvssdhsdvfuhv", null);
INSERT INTO hotel_reservation.user(id, username, email, password, role) VALUES(UUID(), "   Sammy15", "samgrip@gmail.com", "disnusdndfuvnygnfb", "Admin");
INSERT INTO hotel_reservation.user(id, username, email, password, role) VALUES(UUID(), "Kateeekate", "bluekate@gmail.com", "gngivungbhndAHJUHBBfimihmhgng", null);
INSERT INTO hotel_reservation.user VALUES(UUID(), "Mackenzie89", "mackenzie89@gmail.com", "monkey.jpg", "INIUNUvyubtyvytvYVYTVtyvutbyui", null);
INSERT INTO hotel_reservation.user VALUES(UUID(), "Danielo", "DanielMan@gmail.com", "lion.jpg", "IUNiunjuUVGUVYVCdcdrCTCONiiomnIN", null);
INSERT INTO hotel_reservation.user VALUES(UUID(), "Jake55", "jakeChrome@gmail.com", "default.jpg", "IUNJNSNDUISNnjikoimoomninJDJSNDS", null);
INSERT INTO hotel_reservation.reservation VALUES(UUID(), "Alex", "alexpie@gmail.com", "503029495", 1, 1, "2020-5-20", "2020-5-25", "male", "2000-1-15", NOW(), "Alexander", "suite");
INSERT INTO hotel_reservation.reservation VALUES(UUID(), "Sam", "samgrip@gmail.com", "98596834", 3, 2, "2020-5-10", "2020-5-30", "male", "1999-12-2", NOW(), "   Sammy15", "luxury");
INSERT INTO hotel_reservation.reservation VALUES(UUID(), "Kate", "bluekate@gmail.com", "21250903", 0, 0, "2020-5-1", "2020-5-23", "female", "1996-2-17", NOW(), "Kateeekate", "family");
INSERT INTO hotel_reservation.reservation VALUES(UUID(), "Mackenzie", "mackenzie89@gmail.com", "324544556", 3, 0, "2020-5-5", "2020-5-15", "female", "2000-2-28", NOW(), "Mackenzie89", "deluxe");
#intentional error to show that you can't insert value when there aren't available rooms 
INSERT INTO hotel_reservation.reservation VALUES(UUID(), "Daniel", "DanielMan@gmail.com", "324592866", 0, 2, "2020-6-20", "2020-6-29", "male", "1994-4-28", NOW(), "Danielo", "luxury");


#1) How to add word "Sir" before the name of each person which booked the reservation and is a male ?
SELECT CONCAT('Sir ', client_name) FROM hotel_reservation.reservation WHERE gender = 'male';

#2) How to know the length of the user's password ?
SELECT CHAR_LENGTH(password) FROM hotel_reservation.user WHERE profile_picture = 'default.png';

#3) How to get user's name all lower case ?
SELECT LOWER(username) FROM hotel_reservation.user WHERE role="Admin";  

#4) How to get room's type all upper case ?
SELECT UPPER(type) FROM hotel_reservation.room WHERE quantity < 5;

#5) How to replace all the sign (-) from date with (/) in checkin date ?
SELECT REPLACE(checkin_date,'-','/') FROM hotel_reservation.reservation WHERE gender = 'female';

#6) How to get the reverse of the national id of a person that booked a room ?
SELECT REVERSE(national_id) FROM hotel_reservation.reservation WHERE adults = 3;

#7) How to get the last 12 characters from room id ?
SELECT RIGHT(id, 12) FROM hotel_reservation.room WHERE quantity < 3;
 
#8) How to get the first 8 characters from user id ?
SELECT LEFT(id, 8) FROM hotel_reservation.user WHERE role is NULL;

#9) How to get a substring of 4 characters starting from the forth character of email of a user ?
SELECT SUBSTRING(email, 4, 4) FROM hotel_reservation.user where profile_picture != 'default.png';

#10) How to get string result excluding spaces from user's name ?
SELECT TRIM(username) FROM hotel_reservation.user WHERE email = 'samgrip@gmail.com';

#11) How to get average of adults ?
SELECT AVG(adults) FROM hotel_reservation.reservation;

#12) How to get the floor(largest integer value that is <= to a number) ?
SELECT FLOOR(AVG(adults)) FROM hotel_reservation.reservation;

#13) How to get the floor(smallest integer value that is >= to a number) ?
SELECT CEIL(AVG(adults)) FROM hotel_reservation.reservation;

#14) How to return the maximum quantity of room ?
SELECT MAX(quantity) FROM hotel_reservation.room;

#15) How to return the minimum number of children ?
SELECT MIN(children) FROM hotel_reservation.reservation;

#16) How to return the power 2 of the minimum quantity of rooms ?
SELECT POW(MIN(quantity), 2) FROM hotel_reservation.room;

#17) How to return the square root of the maximum quantity of rooms ?
SELECT SQRT(MAX(quantity)) FROM hotel_reservation.room;

#18) How to return sum of the quantity of rooms available to know the total ?
SELECT SUM(quantity) FROM hotel_reservation.room;

#19) How to return the number of days between the checkin and checkout of a reservation ?
SELECT DATEDIFF(checkout_date, checkin_date) FROM hotel_reservation.reservation;

#20) How to add 50 days to date posted a result and return the new date ?
SELECT DATE_ADD(date_posted, INTERVAL 50 DAY) FROM hotel_reservation.reservation;






#FUNCTIONS

SELECT COUNT(*), room_type FROM reservation GROUP BY room_type; 
SELECT COUNT(*), profile_picture FROM user GROUP BY profile_picture; 
SELECT COUNT(client_name), adults FROM reservation GROUP BY adults > 0;


# SUB QUERIES
SELECT * FROM user WHERE email IN (SELECT email FROM reservation WHERE client_name ="Sam");
SELECT client_name FROM reservation WHERE room_type IN (SELECT type FROM room WHERE quantity = 5);
SELECT * FROM user WHERE username IN (SELECT user_username FROM reservation WHERE room_type IN (SELECT type FROM room WHERE quantity > 4) );

# JOINS 
SELECT user.username, reservation.client_name FROM user INNER JOIN reservation ON user.email = reservation.email; # INNER JOIN
SELECT * FROM user LEFT OUTER JOIN reservation ON user.username = reservation.user_username; # LEFT OUTER JOIN
SELECT * FROM reservation RIGHT OUTER JOIN room ON room.type = reservation.room_type; # RIGHT OUTER JOIN
SELECT * FROM user LEFT OUTER JOIN reservation ON user.email = reservation.email UNION SELECT * FROM user RIGHT OUTER JOIN reservation ON user.email = reservation.email; #FULL OUTER JOIN
SELECT * FROM reservation A, reservation B; # SELF JOIN

#UPDATE DATA
UPDATE hotel_reservation.user SET profile_picture="lion.jpg" WHERE username="Alexander";
UPDATE hotel_reservation.user SET username="MarShallOwn" WHERE email="samgrip@gmail.com";
UPDATE hotel_reservation.reservation SET adults=2 WHERE email="samgrip@gmail.com";
UPDATE hotel_reservation.room SET quantity=4 WHERE type="family";
#intentional error to show that we can't add this type of room when it isn't avaiable
UPDATE hotel_reservation.reservation SET room_type="luxury" WHERE email="bluekate@gmail.com";


# SHOW ALL ROWS FOR EACH TABLE
SELECT * FROM hotel_reservation.user;
SELECT * FROM hotel_reservation.reservation;
SELECT * FROM hotel_reservation.room;


# DELETE ROWS
DELETE FROM hotel_reservation.reservation WHERE (email="alexpie@gmail.com" AND id <> '');
DELETE FROM hotel_reservation.reservation WHERE (email="samgrip@gmail.com" AND id <> '');
DELETE FROM hotel_reservation.reservation WHERE (email="bluekate@gmail.com" AND id <> '');
DELETE FROM hotel_reservation.reservation WHERE (email="mackenzie89@gmail.com" AND id <> '');
DELETE FROM hotel_reservation.user WHERE (email="alexpie@gmail.com" AND id <> '');
DELETE FROM hotel_reservation.user WHERE (email="samgrip@gmail.com" AND id <> '');
DELETE FROM hotel_reservation.user WHERE (email="bluekate@gmail.com" AND id <> '');
DELETE FROM hotel_reservation.user WHERE (email="mackenzie89@gmail.com" AND id <> '');
DELETE FROM hotel_reservation.user WHERE (email="DanielMan@gmail.com" AND id <> '');
DELETE FROM hotel_reservation.user WHERE (email="jakeChrome@gmail.com" AND id <> '');
DELETE FROM hotel_reservation.room WHERE type = "suite";
DELETE FROM hotel_reservation.room WHERE type = "family";
DELETE FROM hotel_reservation.room WHERE type = "deluxe";
DELETE FROM hotel_reservation.room WHERE type = "classic";
DELETE FROM hotel_reservation.room WHERE type = "superior";
DELETE FROM hotel_reservation.room WHERE type = "luxury";



#DROP TABLES
DROP TABLE hotel_reservation.reservation;
DROP TABLE hotel_reservation.user;
DROP TABLE hotel_reservation.room;

#DROP DATABASE
DROP DATABASE hotel_reservation;