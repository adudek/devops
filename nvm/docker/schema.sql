CREATE DATABASE nvm;
USE nvm;
CREATE TABLE Address (
    PersonID int,
    LastName varchar(255),
    FirstName varchar(255),
    Address varchar(255),
    City varchar(255)
);

INSERT INTO Address (personid, lastname, firstname, address, city) values (1234, LEFT(UUID(), 8), LEFT(UUID(), 11), LEFT(UUID(), 16), LEFT(UUID(), 6));
