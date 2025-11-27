DROP TABLE IF EXISTS attendance;
DROP TABLE IF EXISTS session;
DROP TABLE IF EXISTS member_program;
DROP TABLE IF EXISTS payment;
DROP TABLE IF EXISTS membership;
DROP TABLE IF EXISTS membership_type;
DROP TABLE IF EXISTS training_program;
DROP TABLE IF EXISTS trainer;
DROP TABLE IF EXISTS member;

CREATE TABLE member
(
	member_id      SERIAL       PRIMARY KEY,
	first_name     VARCHAR(50)  NOT NULL,
	last_name      VARCHAR(50)  NOT NULL,
	date_of_birth  DATE         NOT NULL,
	join_date      DATE         NOT NULL DEFAULT CURRENT_DATE,
	is_active      BOOLEAN      NOT NULL DEFAULT TRUE,
	CONSTRAINT chk_member_birthdate
		CHECK (date_of_birth <= CURRENT_DATE)
);

CREATE TABLE trainer
(
	trainer_id             SERIAL       PRIMARY KEY,
	first_name             VARCHAR(50)  NOT NULL,
	last_name              VARCHAR(50)  NOT NULL,
	primary_specialization VARCHAR(100) NOT NULL,
	qualification_level    VARCHAR(20)  NOT NULL,
	years_of_experience    INT          NOT NULL,
	supervisor_trainer_id  INT          NULL
		REFERENCES trainer(trainer_id),
	is_active              BOOLEAN      NOT NULL DEFAULT TRUE,
	CONSTRAINT chk_trainer_level
		CHECK (qualification_level IN ('junior','middle','senior')),
	CONSTRAINT chk_trainer_experience
		CHECK (years_of_experience >= 0)
);

CREATE TABLE training_program
(
	program_id       SERIAL        PRIMARY KEY,
	program_name     VARCHAR(100)  NOT NULL UNIQUE,
	program_type     VARCHAR(20)   NOT NULL,
	difficulty_level VARCHAR(20)   NOT NULL,
	schedule_pattern VARCHAR(100)  NULL,
	CONSTRAINT chk_program_type
		CHECK (program_type IN ('group','individual')),
	CONSTRAINT chk_program_difficulty
		CHECK (difficulty_level IN ('beginner','intermediate','advanced'))
);

CREATE TABLE membership_type
(
	membership_type_id SERIAL        PRIMARY KEY,
	type_name          VARCHAR(50)   NOT NULL UNIQUE,
	duration_days      INT           NOT NULL,
	price              NUMERIC(10,2) NOT NULL,
	visit_limit        INT           NULL,
	CONSTRAINT chk_membership_duration
		CHECK (duration_days > 0),
	CONSTRAINT chk_membership_price
		CHECK (price >= 0),
	CONSTRAINT chk_membership_visit_limit
		CHECK (visit_limit IS NULL OR visit_limit > 0)
);

CREATE TABLE member_program
(
	member_id       INT NOT NULL
		REFERENCES member(member_id),
	program_id      INT NOT NULL
		REFERENCES training_program(program_id),
	enrollment_date DATE NOT NULL DEFAULT CURRENT_DATE,
	PRIMARY KEY (member_id, program_id)
);

CREATE TABLE session
(
	session_id        SERIAL        PRIMARY KEY,
	program_id        INT           NOT NULL
		REFERENCES training_program(program_id),
	trainer_id        INT           NOT NULL
		REFERENCES trainer(trainer_id),
	session_start     TIMESTAMP     NOT NULL,
	duration_minutes  INT           NOT NULL,
	CONSTRAINT chk_session_duration
		CHECK (duration_minutes > 0)
);

CREATE TABLE membership
(
	membership_id       SERIAL        PRIMARY KEY,
	member_id           INT           NOT NULL
		REFERENCES member(member_id),
	membership_type_id  INT           NOT NULL
		REFERENCES membership_type(membership_type_id),
	start_date          DATE          NOT NULL DEFAULT CURRENT_DATE,
	end_date            DATE          NULL,
	is_active           BOOLEAN       NOT NULL DEFAULT TRUE,
	CONSTRAINT chk_membership_dates
		CHECK (end_date IS NULL OR end_date >= start_date)
);

CREATE TABLE payment
(
	payment_id      SERIAL        PRIMARY KEY,
	membership_id   INT           NOT NULL
		REFERENCES membership(membership_id),
	payment_date    DATE          NOT NULL DEFAULT CURRENT_DATE,
	amount          NUMERIC(10,2) NOT NULL,
	payment_method  VARCHAR(20)   NOT NULL,
	status          VARCHAR(20)   NOT NULL DEFAULT 'completed',
	CONSTRAINT chk_payment_amount
		CHECK (amount > 0),
	CONSTRAINT chk_payment_method
		CHECK (payment_method IN ('card','cash','transfer')),
	CONSTRAINT chk_payment_status
		CHECK (status IN ('completed','pending','failed'))
);

CREATE TABLE attendance
(
	attendance_id  SERIAL        PRIMARY KEY,
	session_id     INT           NOT NULL
		REFERENCES session(session_id),
	member_id      INT           NOT NULL
		REFERENCES member(member_id),
	attended       BOOLEAN       NOT NULL DEFAULT TRUE,
	checkin_time   TIMESTAMP     NULL,
	CONSTRAINT uq_attendance_session_member
		UNIQUE (session_id, member_id)
);
