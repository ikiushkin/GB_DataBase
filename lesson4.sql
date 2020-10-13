/* task1: Создать VIEW на основе запросов, которые вы сделали в ДЗ к уроку 3 */

use geodata;

CREATE VIEW `city_info_view` AS 
select ci.id, ci.title as city_title, ci.important, re.title as region_title, co.title as country_title from _cities ci
left join _regions re on re.id = ci.region_id
inner join _countries co on co.id = ci.country_id
where ci.id = 1;

CREATE VIEW `cities_from_region_view` AS
select ci.id, ci.country_id, ci.important, ci.region_id, ci.title, re.title as region_title from _cities ci
inner join _regions re on re.id = ci.region_id
where re.title = 'Московская область';

use employees;

CREATE VIEW `avg_dep_sal_view` AS
select departments.dept_no, departments.dept_name, (
	select format(avg(salary), 2) from salaries
    inner join dept_emp on dept_emp.emp_no = salaries.emp_no
	where dept_emp.dept_no = departments.dept_no and salaries.to_date = '9999-01-01'
) as average from departments;

CREATE VIEW `max_emp_sal_view` AS
select *, (
	select max(salary) from salaries
    where salaries.emp_no = employees.emp_no
) as max_salary
from employees; 

CREATE VIEW `dept_emps_count_view` AS
select *, (
	select count(*) from dept_emp where departments.dept_no = dept_emp.dept_no and dept_emp.to_date = '9999-01-01'
) as empl_count from departments;

CREATE VIEW `sum_dept_sal_view` AS
select *, (	
    select sum(salary) from salaries
    inner join dept_emp on dept_emp.emp_no = salaries.emp_no
    where dept_emp.dept_no = departments.dept_no and salaries.to_date = '9999-01-01'
) as summary_salary from departments;

/* task2: Создать функцию, которая найдет менеджера по имени и фамилии. */

DROP FUNCTION IF EXISTS mng_id_by_name_function;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` FUNCTION `mng_id_by_name_function`(`name` varchar(255)) RETURNS int(11)
    READS SQL DATA
BEGIN

RETURN 
(select dm.emp_no from dept_manager dm
inner join employees e on dm.emp_no = e.emp_no
where concat(e.first_name, ' ', e.last_name) = name and dm.to_date = '9999-01-01' limit 1);

END$$
DELIMITER ;

/* task3: Создать триггер, который при добавлении нового сотрудника будет выплачивать ему вступительный бонус, занося запись об этом в таблицу salary. */

DROP TRIGGER IF EXISTS `employees`.`employees_AFTER_INSERT`;

DELIMITER $$
USE `employees`$$
CREATE DEFINER=`root`@`localhost` TRIGGER `employees_AFTER_INSERT` AFTER INSERT ON `employees` FOR EACH ROW BEGIN

INSERT INTO `employees`.`salaries` (`emp_no`, `salary`, `from_date`, `to_date`) 
VALUES (NEW.emp_no, 1000, NEW.hire_date, date_add(NEW.hire_date, INTERVAL 1 MONTH));

END$$
DELIMITER ;
