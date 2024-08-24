-- Insert RoomTypes
INSERT INTO bookings_roomtype (id, name, description) VALUES
(1, 'Conference', 'A room for holding conferences'),
(2, 'Lecture', 'A lecture hall'),
(3, 'Office', 'A personal office space');
SELECT setval('bookings_roomtype_id_seq', 3);

-- Insert Rooms
INSERT INTO bookings_room (id, number, name, capacity, description) VALUES
(1, '101', 'Main Conference Room', 50, 'Equipped with projector'),
(2, '202', 'Lecture Hall A', 100, 'Amplified sound system'),
(3, '303', 'Executive Office', 5, 'Includes meeting area');
SELECT setval('bookings_room_id_seq', 3);


-- Insert Room and RoomType associations into the many-to-many table
INSERT INTO bookings_room_room_types (room_id, roomtype_id) VALUES
(1, 1),  -- Main Conference Room has type Conference
(2, 2),  -- Lecture Hall A has type Lecture
(3, 3),  -- Executive Office has type Office
(3, 1);  -- Executive Office also has type Conference
SELECT setval('bookings_room_room_types_id_seq', 4);

-- Insert Staff
INSERT INTO bookings_staff (id, name, email, position) VALUES
(1, 'John Doe', 'john.doe@example.com', 'Manager'),
(2, 'Jane Smith', 'jane.smith@example.com', 'Lecturer'),
(3, 'Emily Davis', 'emily.davis@example.com', 'Executive Assistant');
SELECT setval('bookings_staff_id_seq', 3);

-- Insert Bookings
INSERT INTO bookings_booking (id, staff_id, room_id, start_time, end_time, purpose) VALUES
(1, 1, 1, '2024-08-18 09:00:00', '2024-08-18 11:00:00', 'Monthly staff meeting'),
(2, 2, 2, '2024-08-19 12:00:00', '2024-08-19 14:00:00', 'Guest lecture on AI'),
(3, 3, 3, '2024-08-18 15:00:00', '2024-08-18 16:00:00', 'Project planning'),
(4, 1, 1, '2024-08-19 10:00:00', '2024-08-19 12:00:00', 'Client presentation'),
(5, 2, 3, '2024-08-19 15:00:00', '2024-08-19 16:00:00', 'Team building workshop'),
(6, 3, 3, '2024-08-22 14:00:00', '2024-08-22 15:30:00', 'One-on-one coaching'),
(7, 1, 3, '2024-08-24 11:00:00', '2024-08-24 13:00:00', 'Quarterly business review'),
(8, 2, 1, '2024-08-24 09:30:00', '2024-08-24 10:30:00', 'Networking event'),
(9, 3, 2, '2024-08-24 11:00:00', '2024-08-24 12:00:00', 'Finance meeting'),
(10, 1, 3, '2024-08-26 16:00:00', '2024-08-26 17:00:00', 'Strategy meeting'),
(11, 2, 1, '2024-08-26 09:00:00', '2024-08-26 10:00:00', 'Marketing discussion'),
(12, 3, 2, '2024-08-26 11:00:00', '2024-08-26 12:30:00', 'HR interview'),
(13, 1, 3, '2024-08-27 14:00:00', '2024-08-27 15:00:00', 'Product launch review'),
(14, 2, 3, '2024-08-28 10:00:00', '2024-08-28 11:00:00', 'Legal consultation'),
(15, 3, 1, '2024-08-28 13:00:00', '2024-08-28 14:00:00', 'IT system update'),
(16, 1, 2, '2024-08-30 15:00:00', '2024-08-30- 17:00:00', 'End of year summary'),
(17, 2, 1, '2024-08-30 08:00:00', '2024-08-30 09:00:00', 'Breakfast networking'),
(18, 3, 3, '2024-08-30 12:00:00', '2024-08-30 13:30:00', 'Client feedback session'),
(19, 1, 1, '2024-09-01 14:30:00', '2024-09-01 15:30:00', 'Vendor meeting'),
(20, 2, 2, '2024-09-02 10:00:00', '2024-09-02 11:00:00', 'Research presentation'),
(21, 3, 1, '2024-09-03 09:00:00', '2024-09-03 10:30:00', 'Innovation brainstorming'),
(22, 1, 3, '2024-09-04 12:00:00', '2024-09-04 13:00:00', 'Staff appraisal'),
(23, 2, 1, '2024-09-05 13:00:00', '2024-09-05 14:00:00', 'Partnership exploration'),
(24, 3, 2, '2024-09-06 14:00:00', '2024-09-06 15:00:00', 'Annual report analysis'),
(25, 1, 2, '2024-09-07 09:00:00', '2024-09-07 10:30:00', 'Community outreach'),
(26, 2, 1, '2024-09-08 11:00:00', '2024-09-08 12:00:00', 'Technical discussion'),
(27, 3, 3, '2024-09-09 15:00:00', '2024-09-09 16:30:00', 'Operational review'),
(28, 1, 1, '2024-09-10 08:30:00', '2024-09-10 09:30:00', 'Sales strategy meeting'),
(29, 2, 3, '2024-09-11 14:00:00', '2024-09-11 15:00:00', 'Companywide update'),
(30, 3, 2, '2024-09-12 10:00:00', '2024-09-12 11:00:00', 'Team dynamics workshop'),
(31, 1, 2, '2024-09-13 12:30:00', '2024-09-13 13:30:00', 'Internal audit'),
(32, 2, 1, '2024-09-14 09:00:00', '2024-09-14 10:30:00', 'Future trends seminar'),
(33, 3, 3, '2024-09-14 11:00:00', '2024-09-14 12:30:00', 'Management training');
SELECT setval('bookings_booking_id_seq', 33);
