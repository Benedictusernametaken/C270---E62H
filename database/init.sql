-- ==========================================
-- NUTRITRACK SYSTEM INITIALIZATION SCHEMA
-- ==========================================

-- 1. USER MANAGEMENT & MACRO CONFIGURATION (Member 1 & 4)
CREATE TABLE IF NOT EXISTS users (
    user_id SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS macro_profiles (
    profile_id SERIAL PRIMARY KEY,
    user_id INT REFERENCES users(user_id) ON DELETE CASCADE,
    daily_calorie_target INT NOT NULL,
    target_protein_g INT NOT NULL,
    target_carbs_g INT NOT NULL,
    target_fats_g INT NOT NULL,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 2. VENDOR PORTAL & MENU ARCHITECTURE (Member 2 & 5)
CREATE TABLE IF NOT EXISTS vendors (
    vendor_id SERIAL PRIMARY KEY,
    restaurant_name VARCHAR(100) NOT NULL,
    cuisine_type VARCHAR(50),
    is_verified BOOLEAN DEFAULT FALSE
);

CREATE TABLE IF NOT EXISTS meals (
    meal_id SERIAL PRIMARY KEY,
    vendor_id INT REFERENCES vendors(vendor_id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    base_price DECIMAL(10, 2) NOT NULL,
    base_calories INT NOT NULL,
    base_protein INT NOT NULL,
    base_carbs INT NOT NULL,
    base_fats INT NOT NULL
);

-- 3. INTERACTIVE MEAL-BUILDER (CRUD) INGREDIENTS (Member 3)
CREATE TABLE IF NOT EXISTS ingredients (
    ingredient_id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    unit VARCHAR(20) DEFAULT 'grams',
    calories_per_unit INT NOT NULL,
    protein_per_unit INT NOT NULL,
    carbs_per_unit INT NOT NULL,
    fats_per_unit INT NOT NULL,
    price_per_unit DECIMAL(10, 2) NOT NULL
);

CREATE TABLE IF NOT EXISTS meal_ingredients (
    meal_id INT REFERENCES meals(meal_id) ON DELETE CASCADE,
    ingredient_id INT REFERENCES ingredients(ingredient_id) ON DELETE CASCADE,
    default_quantity INT NOT NULL,
    PRIMARY KEY (meal_id, ingredient_id)
);

-- 4. DAILY FITNESS LOGGING & PROGRESS TRACKING (Member 4)
CREATE TABLE IF NOT EXISTS daily_logs (
    log_id SERIAL PRIMARY KEY,
    user_id INT REFERENCES users(user_id) ON DELETE CASCADE,
    log_date DATE DEFAULT CURRENT_DATE,
    total_calories_consumed INT DEFAULT 0,
    total_protein_consumed INT DEFAULT 0,
    total_carbs_consumed INT DEFAULT 0,
    total_fats_consumed INT DEFAULT 0
);

-- 5. SCHEDULED SUBSCRIPTION ENGINE (Member 6)
CREATE TABLE IF NOT EXISTS subscriptions (
    subscription_id SERIAL PRIMARY KEY,
    user_id INT REFERENCES users(user_id) ON DELETE CASCADE,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    status VARCHAR(20) DEFAULT 'active' -- active, paused, cancelled
);

CREATE TABLE IF NOT EXISTS subscription_schedule (
    schedule_id SERIAL PRIMARY KEY,
    subscription_id INT REFERENCES subscriptions(subscription_id) ON DELETE CASCADE,
    delivery_day_of_week INT NOT NULL, -- 1 (Monday) to 7 (Sunday)
    meal_id INT REFERENCES meals(meal_id),
    delivery_time_slot VARCHAR(20) NOT NULL -- Morning, Afternoon, Evening
);

-- ==========================================
-- INSERT SEED DATA FOR TESTING
-- ==========================================
INSERT INTO vendors (restaurant_name, cuisine_type, is_verified) VALUES 
('Lean & Mean Kitchen', 'Healthy Western', true);

INSERT INTO meals (vendor_id, name, description, base_price, base_calories, base_protein, base_carbs, base_fats) VALUES 
(1, 'Sous-Vide Chicken Breast Bowl', 'Fluffy brown rice paired with clean chicken breast and broccoli.', 12.50, 520, 45, 50, 10);

INSERT INTO ingredients (name, unit, calories_per_unit, protein_per_unit, carbs_per_unit, fats_per_unit, price_per_unit) VALUES
('Extra Chicken Breast', '50g', 82, 15, 0, 1, 2.50),
('Avocado Scoop', '30g', 48, 1, 3, 4, 1.80);