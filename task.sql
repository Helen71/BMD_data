-- створення початкової таблиці дял завантаження даних
CREATE TABLE my_table (
    data TEXT,
    user1 TEXT,
    mobile_model_name TEXT,
  country TEXT,
  book TEXT,
  chapter TEXT,
  bookstep TEXT,
  choise_text TEXT,
  price INT
);
select * from my_table;

\copy my_table (data, user1, mobile_model_name, country,book,chapter,bookstep,choise_text,price )
FROM 'C:\\Users\\Olena\\Downloads\\test_task_1.tsv'
DELIMITER ','
CSV HEADER;

-- розподілення по країнам
ALTER TABLE my_table
ADD COLUMN continent VARCHAR;
UPDATE my_table
SET continent= CASE
        WHEN country IN ('Algeria', 'Angola', 'Benin', 'Botswana', 'Burkina Faso', 'Burundi', 'Cabo Verde', 'Cameroon', 'Central African Republic', 'Chad', 'Comoros', 'Congo - Brazzaville', 'Congo - Kinshasa', 'Djibouti', 'Egypt', 'Equatorial Guinea', 'Eritrea', 'Eswatini', 'Ethiopia', 'Gabon', 'Gambia', 'Ghana', 'Guinea', 'Guinea-Bissau', 'Ivory Coast', 'Kenya', 'Lesotho', 'Liberia', 'Libya', 'Madagascar', 'Malawi', 'Mali', 'Mauritania', 'Mauritius', 'Morocco', 'Mozambique', 'Namibia', 'Niger', 'Nigeria', 'Rwanda', 'Sao Tome & Principe', 'Senegal', 'Seychelles', 'Sierra Leone', 'Somalia', 'South Africa', 'South Sudan', 'Sudan', 'Tanzania', 'Togo', 'Tunisia', 'Uganda', 'Zambia', 'Zimbabwe')
            THEN 'Africa'
        WHEN country IN ('Albania', 'Faroe Islands','Gibraltar','Guernsey','Jersey','Andorra', 'Armenia', 'Austria', 'Azerbaijan', 'Belarus', 'Belgium', 'Bosnia & Herzegovina', 'Bulgaria', 'Croatia', 'Cyprus', 'Czechia', 'Denmark', 'Estonia', 'Finland', 'France', 'Georgia', 'Germany', 'Greece', 'Hungary', 'Iceland', 'Ireland', 'Italy', 'Kazakhstan', 'Kosovo', 'Latvia', 'Liechtenstein', 'Lithuania', 'Luxembourg', 'Malta', 'Moldova', 'Monaco', 'Montenegro', 'Netherlands', 'North Macedonia', 'Norway', 'Poland', 'Portugal', 'Romania', 'Russia', 'San Marino', 'Serbia', 'Slovakia', 'Slovenia', 'Spain', 'Sweden', 'Switzerland', 'Ukraine', 'United Kingdom', 'Vatican City')
            THEN 'Europe'
        WHEN country IN ('Antigua & Barbuda', 'Cayman Islands','Puerto Rico','St. Kitts & Nevis','St. Lucia','St. Vincent & Grenadines','U.S. Virgin Islands',
    'Bahamas', 'Barbados', 'Belize', 'Canada', 'Costa Rica', 'Cuba', 'Dominica', 'Dominican Republic', 'El Salvador', 'Grenada', 'Guatemala', 'Haiti', 'Honduras', 'Jamaica', 'Mexico', 'Nicaragua', 'Panama', 'Saint Kitts & Nevis', 'Saint Lucia', 'Saint Vincent & Grenadines', 'Trinidad & Tobago', 'United States')
            THEN 'North America'
        WHEN country IN ('Argentina','Aruba','Guadeloupe','French Guiana','Guadeloup', 'Bolivia', 'Brazil','Curaçao', 'Chile', 'Colombia', 'Ecuador', 'Guyana', 'Paraguay', 'Peru', 'Suriname', 'Uruguay', 'Venezuela')
            THEN 'South America'
        WHEN country IN ('Australia','New Caledonia', 'French Polynesia','Fiji', 'Kiribati', 'Marshall Islands', 'Micronesia', 'Nauru', 'New Zealand', 'Palau', 'Papua New Guinea', 'Samoa', 'Solomon Islands', 'Tonga', 'Tuvalu', 'Vanuatu')
            THEN 'Oceania'
        WHEN country IN ('Afghanistan','Hong Kong','Bahrain', 'Bangladesh', 'Bhutan', 'Brunei', 'Cambodia', 'China', 'East Timor', 'India', 'Indonesia', 'Iran', 'Iraq', 'Israel', 'Japan', 'Jordan', 'Kuwait', 'Kyrgyzstan', 'Laos', 'Lebanon', 'Malaysia', 'Maldives', 'Mongolia', 'Myanmar (Burma)', 'Nepal', 'North Korea', 'Oman', 'Pakistan', 'Palestine', 'Philippines', 'Qatar', 'Saudi Arabia', 'Singapore', 'South Korea', 'Sri Lanka', 'Syria', 'Taiwan', 'Tajikistan', 'Thailand', 'Turkey', 'Turkmenistan', 'United Arab Emirates', 'Uzbekistan', 'Vietnam', 'Yemen')
            THEN 'Asia'
        ELSE 'Other'
    END;

-- розподілення по ос
ALTER TABLE my_table
ADD COLUMN os_name VARCHAR;
UPDATE my_table
SET os_name = 'iOS'
WHERE mobile_model_name IN (
    'iPad',
    'iPad 3rd gen',
    'iPad 5th gen',
    'iPad 6th gen',
    'iPad Air',
    'iPad Air 2',
    'iPad Mini 2',
    'iPad Mini 4',
    'iPad Pro 10.5',
    'iPad Pro 12.9 2nd gen',
    'iPad Pro 12.9 inch',
    'iPad Pro 9.7 inch',
    'iPhone',
    'iPhone 5s',
    'iPhone 6',
    'iPhone 6 Plus',
    'iPhone 6s',
    'iPhone 6s Plus',
    'iPhone 7',
    'iPhone 7 Plus',
    'iPhone 8',
    'iPhone 8 Plus',
    'iPhone SE',
    'iPhone X',
    'iPhone XR',
    'iPhone XS',
    'iPhone XS Max',
    'iPod Touch',
    'iPod touch 6th gen',
    'A002OP'  -- iPhone SE 2nd gen
);
-- топ 10 по кожному континенту
WITH ranked_choises AS (
  SELECT 
    choise_text, 
    continent, 
    SUM(price) AS total_price,
    ROW_NUMBER() OVER (PARTITION BY continent ORDER BY SUM(price) DESC) AS rank_desc,
    ROW_NUMBER() OVER (PARTITION BY continent ORDER BY SUM(price) ASC) AS rank_asc
  FROM my_table
  GROUP BY choise_text, continent
)

SELECT 
  choise_text, 
  continent, 
  total_price, 
  CASE 
    WHEN rank_desc <= 10 THEN 'Top 10 High'
    WHEN rank_asc <= 10 THEN 'Top 10 Low'
  END AS rank_category
FROM ranked_choises
WHERE rank_desc <= 10 OR rank_asc <= 10
ORDER BY continent, rank_category, total_price DESC;

-- топ 10 по кожній ос
WITH ranked_choises AS (
  SELECT 
    choise_text, 
    os_name, 
    SUM(price) AS total_price,
    ROW_NUMBER() OVER (PARTITION BY os_name ORDER BY SUM(price) DESC) AS rank_desc,
    ROW_NUMBER() OVER (PARTITION BY os_name ORDER BY SUM(price) ASC) AS rank_asc
  FROM my_table
  GROUP BY choise_text, os_name
)

SELECT 
  choise_text, 
  os_name, 
  total_price, 
  CASE 
    WHEN rank_desc <= 10 THEN 'Top 10 High'
    WHEN rank_asc <= 10 THEN 'Top 10 Low'
  END AS rank_category
FROM ranked_choises
WHERE rank_desc <= 10 OR rank_asc <= 10
ORDER BY os_name, rank_category, total_price DESC;

-- топ 3 по кожній книзі
WITH ranked_choises AS (
  SELECT 
    choise_text, 
    book, 
    SUM(price) AS total_price,
    ROW_NUMBER() OVER (PARTITION BY book ORDER BY SUM(price) DESC) AS rank_desc,
    ROW_NUMBER() OVER (PARTITION BY book ORDER BY SUM(price) ASC) AS rank_asc
  FROM my_table
  GROUP BY choise_text, book
)

SELECT 
  choise_text, 
  book, 
  total_price, 
  CASE 
    WHEN rank_desc <= 3 THEN 'Top 3 High'
    WHEN rank_asc <= 3 THEN 'Top 3 Low'
  END AS rank_category
FROM ranked_choises
WHERE rank_desc <= 3 OR rank_asc <= 3
ORDER BY book, rank_category, total_price DESC;


-- розподілення костів
WITH min_dates AS (
    SELECT 
        publisher_name, 
        MIN(install_date) AS min_install_date
    FROM 
        my_table2
    GROUP BY 
        publisher_name
)
SELECT 
    t.publisher_name,
    d.min_install_date,
    d.min_install_date + INTERVAL '7 days' AS cost_end_date,
    d.min_install_date + INTERVAL '1 days' AS revenue_date,
    
    -- Сума витрат за кожен з 7 днів
    SUM(CASE WHEN t.install_date = d.min_install_date THEN t.cost ELSE 0 END) AS cost_day_1,
    SUM(CASE WHEN t.install_date = d.min_install_date + INTERVAL '1 days' THEN t.cost ELSE 0 END) AS cost_day_2,
    SUM(CASE WHEN t.install_date = d.min_install_date + INTERVAL '2 days' THEN t.cost ELSE 0 END) AS cost_day_3,
    SUM(CASE WHEN t.install_date = d.min_install_date + INTERVAL '3 days' THEN t.cost ELSE 0 END) AS cost_day_4,
    SUM(CASE WHEN t.install_date = d.min_install_date + INTERVAL '4 days' THEN t.cost ELSE 0 END) AS cost_day_5,
    SUM(CASE WHEN t.install_date = d.min_install_date + INTERVAL '5 days' THEN t.cost ELSE 0 END) AS cost_day_6,
    SUM(CASE WHEN t.install_date = d.min_install_date + INTERVAL '6 days' THEN t.cost ELSE 0 END) AS cost_day_7,
    SUM(CASE WHEN t.install_date = d.min_install_date + INTERVAL '7 days' THEN t.cost ELSE 0 END) AS cost_day_8,
    -- Загальна сума витрат за 7 днів
    SUM(CASE WHEN t.install_date BETWEEN d.min_install_date AND d.min_install_date + INTERVAL '7 days' THEN t.cost ELSE 0 END) AS total_cost,

    -- Сума прибутку на наступний день
    SUM(CASE WHEN t.install_date = d.min_install_date + INTERVAL '1 days' THEN t.revenue_d7 ELSE 0 END) AS total_revenue,

    -- ROAS d7
    CASE 
        WHEN SUM(CASE WHEN t.install_date = d.min_install_date + INTERVAL '1 days' THEN t.revenue_d7 ELSE 0 END) = 0 
             OR SUM(CASE WHEN t.install_date BETWEEN d.min_install_date AND d.min_install_date + INTERVAL '7 days' THEN t.cost ELSE 0 END) = 0 
        THEN 0
        ELSE (SUM(CASE WHEN t.install_date = d.min_install_date + INTERVAL '1 days' THEN t.revenue_d7 ELSE 0 END) 
              / SUM(CASE WHEN t.install_date BETWEEN d.min_install_date AND d.min_install_date + INTERVAL '7 days' THEN t.cost ELSE 0 END) * 100) 
    END AS roas_d7,

    -- Статус (ban/ok)
    CASE 
        WHEN 
            CASE 
                WHEN SUM(CASE WHEN t.install_date = d.min_install_date + INTERVAL '1 days' THEN t.revenue_d7 ELSE 0 END) = 0 
                     OR SUM(CASE WHEN t.install_date BETWEEN d.min_install_date AND d.min_install_date + INTERVAL '7 days' THEN t.cost ELSE 0 END) = 0 
                THEN 0
                ELSE (SUM(CASE WHEN t.install_date = d.min_install_date + INTERVAL '1 days' THEN t.revenue_d7 ELSE 0 END) 
                      / SUM(CASE WHEN t.install_date BETWEEN d.min_install_date AND d.min_install_date + INTERVAL '7 days' THEN t.cost ELSE 0 END) * 100) 
            END < 5 
        THEN 'ban'
        ELSE 'ok'
    END AS status
FROM 
    my_table2 t
JOIN 
    min_dates d ON t.publisher_name = d.publisher_name
GROUP BY 
    t.publisher_name, d.min_install_date
ORDER BY 
    t.publisher_name;

