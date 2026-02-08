SELECT
  CASE
    WHEN MONTHS_BETWEEN(l.end_date, l.start_date) BETWEEN 0 AND 12 THEN '0-12 ay'
    WHEN MONTHS_BETWEEN(l.end_date, l.start_date) BETWEEN 13 AND 24 THEN '13-24 ay'
    WHEN MONTHS_BETWEEN(l.end_date, l.start_date) BETWEEN 25 AND 48 THEN '25-48 ay'
    ELSE '48 ay+'
  END AS muddet_bolgusu,
  SUM(l.loan_amount) AS total_loan_amount
FROM bank_loans l
JOIN bank_customers c ON l.customer_id = c.customer_id
WHERE UPPER(c.status) = 'AKTIV'
GROUP BY
  CASE
    WHEN MONTHS_BETWEEN(l.end_date, l.start_date) BETWEEN 0 AND 12 THEN '0-12 ay'
    WHEN MONTHS_BETWEEN(l.end_date, l.start_date) BETWEEN 13 AND 24 THEN '13-24 ay'
    WHEN MONTHS_BETWEEN(l.end_date, l.start_date) BETWEEN 25 AND 48 THEN '25-48 ay'
    ELSE '48 ay+'
  END
ORDER BY muddet_bolgusu;



select * from bank_customers where rownum = 1;
select * from bank_loans where rownum = 1;
select * from bank_transactions where rownum = 1;



14. Hər müştərinin son 3 ayda kartlar ilə edilən əməliyyatların sayına görə ən aktiv kart növünü müəyyən edin.
select * from bank_cards
select * from BANK_ACCOUNTS
WITH card_txn AS (
    SELECT 
        c.customer_id,
        c.first_name AS ad,
        c.last_name AS soyad,
        card.card_type AS kart_novu,
        COUNT(t.transaction_id) AS tr_sayi,
        ROW_NUMBER() OVER (
            PARTITION BY c.customer_id 
            ORDER BY COUNT(t.transaction_id) DESC
        ) AS rn
    FROM bank_transactions t
    JOIN bank_accounts a ON t.account_id = a.account_id
    JOIN bank_customers c ON c.customer_id = a.customer_id
    JOIN bank_cards card ON card.customer_id = a.customer_id
    WHERE t.transaction_date >= ADD_MONTHS(SYSDATE, -3)
      AND UPPER(a.account_type) = 'CARD ACCOUNT'
    GROUP BY c.customer_id, c.first_name, c.last_name, card.card_type
)
SELECT customer_id, ad, soyad, kart_novu, tr_sayi
FROM card_txn
WHERE rn = 1
ORDER BY tr_sayi DESC;



13.Hər bir müştəri üçün son 1 ildə ən yüksək depozit məbləği ilə saxlanılan hesab növünü və bu hesabın açılış tarixini tapın.

select * from deposits;

SELECT D.CUSTOMER_ID, 
       A.ACCOUNT_TYPE, 
       D.MAX_DEPOSIT, 
       A.DATE_OPENED AS HESAB_ACILIS_TARIXI 
       FROM (
        SELECT CUSTOMER_ID, 
        MAX(DEPOSIT_AMOUNT) AS MAX_DEPOSIT 
        FROM DEPOSITS 
        WHERE START_DATE >= ADD_MONTHS
        (SYSDATE, -12)
         GROUP BY CUSTOMER_ID ) D
          JOIN BANK_ACCOUNTS A ON D.CUSTOMER_ID = A.CUSTOMER_ID

12. Hər müştəri üçün son 1 ildə hər ay üzrə ümumi balans və depozit məbləğini göstərən sorğu:
SELECT
    c.customer_id,
    c.first_name || ' ' || c.last_name AS musteri_adi,
    TO_CHAR(t.transaction_date, 'YYYY-MM') AS ay,
    SUM(t.amount) AS umumibalans,
    SUM(CASE WHEN UPPER(a.account_type) = 'DEPOSIT' THEN t.amount ELSE 0 END) AS depozit_meblegi
FROM bank_transactions t
JOIN bank_accounts a ON t.account_id = a.account_id
JOIN bank_customers c ON a.customer_id = c.customer_id
WHERE t.transaction_date >= ADD_MONTHS(SYSDATE, -12)
GROUP BY
    c.customer_id, c.first_name, c.last_name, TO_CHAR(t.transaction_date, 'YYYY-MM')
ORDER BY
    c.customer_id, ay;
 
 --11. Hər müştərinin son 1 ildə açdığı bütün hesabları və bu hesablara görə edilən əməliyyatların ümumi məbləğini göstərmək: 
 select * from bank_accounts where rownum = 1; 
 select * from bank_transactions where rownum = 1;

SELECT
    c.customer_id,
    c.first_name || ' ' || c.last_name AS musteri_adi,
    a.account_id,
    a.account_type,
    a.date_opened,
    NVL(SUM(t.amount), 0) AS total_transaction_amount
FROM bank_accounts a
JOIN bank_customers c ON c.customer_id = a.customer_id
LEFT JOIN bank_transactions t
    ON a.account_id = t.account_id
   AND t.transaction_date >= ADD_MONTHS(SYSDATE, -12)
WHERE a.date_opened >= ADD_MONTHS(SYSDATE, -12)
GROUP BY
    c.customer_id,
    c.first_name,
    c.last_name,
    a.account_id,
    a.account_type,
    a.date_opened
ORDER BY
    c.customer_id,
    a.date_opened;
10. Müştəri ən çox hansı növ kreditlərə müraciət edir və bu kreditlərin növü ilə müştəriyə təklif olunan ortalama faiz dərəcəsi nə qədər təşkil edir?  
select * from bank_loans where rownum = 1;
SELECT 
    l.loan_type,
    COUNT(l.loan_id) AS müraciət_sayı,
    AVG(l.interest_rate) AS ortalama_faiz_dərəcəsi
FROM bank_loans l
JOIN bank_customers c ON c.customer_id = l.customer_id
GROUP BY l.loan_type
ORDER BY müraciət_sayı DESC;

--9. Hər müştərinin son 6 ay ərzində etdiyi ən yüksək məbləğli əməliyyatla bağlı məlumatları (əməliyyat növü, tarix, balans) göstərin.
select * from bank_transactions where rownum = 1;
SELECT
    c.customer_id,
    c.first_name || ' ' || c.last_name AS musteri_adi,
    t.transaction_date,
    t.transaction_type,
    t.amount
FROM (
    SELECT 
        t.*,
        ROW_NUMBER() OVER (
            PARTITION BY a.customer_id
            ORDER BY t.amount DESC
        ) AS rn
    FROM bank_transactions t
    JOIN bank_accounts a ON t.account_id = a.account_id
    WHERE t.transaction_date >= ADD_MONTHS(SYSDATE, -6)
) t
JOIN bank_accounts a ON t.account_id = a.account_id
JOIN bank_customers c ON a.customer_id = c.customer_id
WHERE rn = 1;



--1. Son 3 ayda ümumilikdə ən çox əməliyyat edən müştəri (Musteri adi) və bu müştərinin əməliyyatlarının ümumi məbləğini göstərən sorğu yazın.   

SELECT *
FROM (
    SELECT
        c.customer_id,
        c.first_name || ' ' || c.last_name AS musteri_adi,
        COUNT(t.transaction_id) AS count_transaction,
        SUM(t.amount) AS total_amount
    FROM bank_transactions t
    JOIN bank_accounts a ON t.account_id = a.account_id
    JOIN bank_customers c ON a.customer_id = c.customer_id
    WHERE t.transaction_date >= ADD_MONTHS(SYSDATE, -3)
    GROUP BY c.customer_id, c.first_name, c.last_name
    ORDER BY COUNT(t.transaction_id) DESC
) sub
WHERE ROWNUM = 1;

--2. Hər müştəri üçün son 1 ildə kart hesabından edilən çıxarışların sayını və bu çıxarışların ümumi məbləğini göstərin.
select * from BANK_TRANSACTIONS;
select * from BANK_ACCOUNTS
SELECT 
    c.customer_id,
    c.first_name,
    c.last_name,
    COUNT(t.transaction_id) AS withdrawal_count,
    SUM(t.amount) AS total_withdrawal_amount
FROM bank_transactions t
JOIN bank_accounts a ON a.account_id = t.account_id
JOIN bank_customers c ON c.customer_id = a.customer_id
WHERE t.transaction_date >= ADD_MONTHS(SYSDATE, -12)
  AND t.transaction_type = 'Withdrawal'
  AND a.account_type = 'Card Account'
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY withdrawal_count DESC;


--8. Son 6 ayda ən yüksək kredit məbləğinə sahib olan müştəri haqqında məlumatlar və kredit məbləğini göstərmək.
SELECT * 
FROM (
    SELECT 
        c.customer_id,
        c.first_name,
        l.loan_id,
        l.loan_amount,
        l.start_date,
        ROW_NUMBER() OVER (ORDER BY l.loan_amount DESC) AS rn
    FROM bank_loans l
    JOIN bank_customers c ON c.customer_id = l.customer_id
    WHERE l.start_date >= ADD_MONTHS(SYSDATE, -6)
) sub
WHERE rn = 1;

--4. Müştərilərin son 1 ildə yalnız depozit hesabları ilə bağlı etdikləri əməliyyatların ümumi məbləğini təhlil edin.
select * from bank_accounts
SELECT 
    c.customer_id,
    c.first_name,
    c.last_name,
    SUM(t.amount) AS total_deposit_transactions
FROM bank_transactions t
JOIN bank_accounts a ON a.account_id = t.account_id
JOIN bank_customers c ON c.customer_id = a.customer_id
WHERE t.transaction_date >= ADD_MONTHS(SYSDATE, -12)
  AND a.account_type = 'Deposit Account'
GROUP BY c.customer_id, c.first_name, c.last_name;


--6. Aktiv depoziti olan müştərilərin depozit və kredit məlumatlarının siyahısını çıxarmaq:
select * from deposits where rownum = 1;
select * from bank_loans where rownum = 1
SELECT 
    c.customer_id,
    c.first_name,
    d.deposit_amount,
    d.start_date AS deposit_start,
    d.end_date AS deposit_end,
    l.loan_type,
    l.loan_amount,
    l.interest_rate
FROM bank_customers c
JOIN deposits d ON c.customer_id = d.customer_id
LEFT JOIN bank_loans l ON c.customer_id = l.customer_id
WHERE d.deposit_type = 'ACTIVE';


---7. Hər müştəri üçün son 1 il ərzində hər ay üzrə ümumi balans və depozit məbləğini göstərmək üçün sorğu yazın:
select * from deposits;
select * from bank_accounts;

SELECT
    C.FIRST_NAME || ' ' || C.LAST_NAME AS MUSTERI_ADI,
    TO_CHAR(T.TRANSACTION_DATE, 'YYYY-MM') AS AY,
    SUM(T.AMOUNT) AS UMUMI_BALANS,
    SUM(CASE WHEN UPPER(A.ACCOUNT_TYPE) = 'DEPOSIT ACCOUNT' THEN T.AMOUNT ELSE 0 END) AS DEPOZIT_MEBLEGI
FROM
    BANK_CUSTOMERS C
JOIN
    BANK_ACCOUNTS A
    ON A.CUSTOMER_ID = C.CUSTOMER_ID
JOIN
    BANK_TRANSACTIONS T
    ON T.ACCOUNT_ID = A.ACCOUNT_ID
WHERE 
    T.TRANSACTION_DATE >= ADD_MONTHS(SYSDATE, -12)
GROUP BY 
    C.FIRST_NAME, C.LAST_NAME, TO_CHAR(T.TRANSACTION_DATE, 'YYYY-MM')
ORDER BY 
    MUSTERI_ADI, AY;

   
--3. Hər müştəri üçün son 6 ay ərzində edilən əməliyyatların sayına görə, ən çox əməliyyat edən hesab növünü müəyyən edin.
SELECT
    musteri_adi,
    hesab_novu
FROM (
    SELECT
        c.customer_id,
        c.first_name || ' ' || c.last_name AS musteri_adi,
        a.account_type AS hesab_novu,
        COUNT(t.transaction_id) AS emeliyyat_sayi,
        ROW_NUMBER() OVER (
            PARTITION BY c.customer_id 
            ORDER BY COUNT(t.transaction_id) DESC
        ) AS rn
    FROM bank_customers c
    JOIN bank_accounts a ON a.customer_id = c.customer_id
    JOIN bank_transactions t ON t.account_id = a.account_id
    WHERE t.transaction_date >= ADD_MONTHS(SYSDATE, -6)
    GROUP BY c.customer_id, c.first_name, c.last_name, a.account_type
)
WHERE rn = 1;
--5. Hər müştəri üçün son 3 ayda, ən çox kart əməliyyatlarını həyata keçirən tarixləri göstərin. 
SELECT
    MUSTERI_ADI,
    TRANSACTION_DATE,
    EMELIYYAT_SAYI
FROM
    (SELECT 
        C.FIRST_NAME || ' ' || C.LAST_NAME AS MUSTERI_ADI,
        TRUNC(T.TRANSACTION_DATE) AS TRANSACTION_DATE,
        COUNT(T.TRANSACTION_ID) AS EMELIYYAT_SAYI,
        RANK() OVER(PARTITION BY C.FIRST_NAME || ' ' || C.LAST_NAME ORDER BY COUNT(T.TRANSACTION_ID) DESC) AS RN
    FROM
        BANK_TRANSACTIONS T
    JOIN 
        BANK_ACCOUNTS  A
        ON A.ACCOUNT_ID=T.ACCOUNT_ID
    JOIN 
        BANK_CUSTOMERS C
        ON C.CUSTOMER_ID=A.CUSTOMER_ID
    WHERE
        T.TRANSACTION_DATE >= ADD_MONTHS(SYSDATE, -3)
        AND UPPER(A.ACCOUNT_TYPE)='CARD ACCOUNT'
    GROUP BY 
        C.FIRST_NAME, C.LAST_NAME, TRUNC(T.TRANSACTION_DATE)
    )
WHERE RN=1;