-- Drop existing tables and functions
DROP TRIGGER IF EXISTS check_bank_id_trigger ON cards;
DROP FUNCTION IF EXISTS check_bank_id_exists;
DROP TABLE IF EXISTS payments;
DROP TABLE IF EXISTS cards;
DROP TABLE IF EXISTS banks;
DROP TABLE IF EXISTS default_banks;
DROP TABLE IF EXISTS settings;

-- Create default_banks table
CREATE TABLE default_banks (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  code TEXT NOT NULL,
  logo_path TEXT,
  support_number TEXT,
  website TEXT,
  is_favorite BOOLEAN DEFAULT FALSE,
  color_hex TEXT,
  priority INTEGER,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create banks table
CREATE TABLE banks (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL,
  name TEXT NOT NULL,
  code TEXT NOT NULL,
  logo_path TEXT,
  support_number TEXT,
  website TEXT,
  is_favorite BOOLEAN DEFAULT FALSE,
  color_hex TEXT,
  priority INTEGER,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE
);

-- Create cards table
CREATE TABLE cards (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL,
  name TEXT NOT NULL,
  bank_id UUID NOT NULL,
  last_4_digits TEXT NOT NULL,
  billing_date DATE,
  due_date DATE,
  card_type TEXT NOT NULL,
  credit_limit DOUBLE PRECISION,
  current_utilization DOUBLE PRECISION,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  is_archived BOOLEAN DEFAULT FALSE,
  is_favorite BOOLEAN DEFAULT FALSE,
  is_default_bank BOOLEAN DEFAULT FALSE,
  is_auto_debit_enabled BOOLEAN DEFAULT FALSE,
  benefit_summary TEXT,
  FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE
);

-- Create payments table
CREATE TABLE payments (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL,
  card_id UUID NOT NULL,
  due_amount DOUBLE PRECISION,
  payment_date DATE,
  is_paid BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  minimum_due_amount DOUBLE PRECISION,
  paid_amount DOUBLE PRECISION,
  due_date DATE,
  statement_amount DOUBLE PRECISION,
  FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE,
  FOREIGN KEY (card_id) REFERENCES cards(id) ON DELETE CASCADE
);

-- Create settings table
CREATE TABLE settings (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL,
  language TEXT,
  currency TEXT,
  theme_mode TEXT,
  notifications_enabled BOOLEAN DEFAULT TRUE,
  reminder_time TIME,
  sync_settings BOOLEAN DEFAULT TRUE,
  utilization_alert_threshold INTEGER DEFAULT 30;
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE
);

-- Create function to validate bank_id
CREATE OR REPLACE FUNCTION check_bank_id_exists()
RETURNS TRIGGER AS $$
BEGIN
  -- First check default_banks
  IF EXISTS (SELECT 1 FROM default_banks WHERE id = NEW.bank_id) THEN
    RETURN NEW;
  END IF;
  
  -- If not found in default_banks, check user's banks
  IF EXISTS (SELECT 1 FROM banks WHERE id = NEW.bank_id AND user_id = NEW.user_id) THEN
    RETURN NEW;
  END IF;
  
  -- If not found in either table, raise exception
  RAISE EXCEPTION 'Invalid bank_id: % not found in default_banks or user banks', NEW.bank_id;
END;
$$ LANGUAGE plpgsql;

-- Create trigger for bank_id validation
CREATE TRIGGER check_bank_id_trigger
  BEFORE INSERT OR UPDATE ON cards
  FOR EACH ROW
  EXECUTE FUNCTION check_bank_id_exists();

-- Enable RLS
ALTER TABLE default_banks ENABLE ROW LEVEL SECURITY;
ALTER TABLE banks ENABLE ROW LEVEL SECURITY;
ALTER TABLE cards ENABLE ROW LEVEL SECURITY;
ALTER TABLE payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE settings ENABLE ROW LEVEL SECURITY;

-- RLS policies for default_banks
CREATE POLICY "Allow read access to default banks"
  ON default_banks
  FOR SELECT
  TO authenticated
  USING (TRUE);

CREATE POLICY "Deny modifications to default banks"
  ON default_banks
  FOR ALL
  TO authenticated
  USING (FALSE);

-- RLS policies for banks
CREATE POLICY "Allow read access to own banks"
  ON banks
  FOR SELECT
  TO authenticated
  USING (user_id = (SELECT auth.uid()));

CREATE POLICY "Allow insert for own banks"
  ON banks
  FOR INSERT
  TO authenticated
  WITH CHECK (user_id = (SELECT auth.uid()));

CREATE POLICY "Allow update for own banks"
  ON banks
  FOR UPDATE
  TO authenticated
  USING (user_id = (SELECT auth.uid()));

CREATE POLICY "Allow delete for own banks"
  ON banks
  FOR DELETE
  TO authenticated
  USING (user_id = (SELECT auth.uid()));

-- RLS policies for cards
CREATE POLICY "Allow read access to own cards"
  ON cards
  FOR SELECT
  TO authenticated
  USING (user_id = (SELECT auth.uid()));

CREATE POLICY "Allow insert for own cards"
  ON cards
  FOR INSERT
  TO authenticated
  WITH CHECK (user_id = (SELECT auth.uid()));

CREATE POLICY "Allow update for own cards"
  ON cards
  FOR UPDATE
  TO authenticated
  USING (user_id = (SELECT auth.uid()));

CREATE POLICY "Allow delete for own cards"
  ON cards
  FOR DELETE
  TO authenticated
  USING (user_id = (SELECT auth.uid()));

-- RLS policies for payments
CREATE POLICY "Allow read access to own payments"
  ON payments
  FOR SELECT
  TO authenticated
  USING (user_id = (SELECT auth.uid()));

CREATE POLICY "Allow insert for own payments"
  ON payments
  FOR INSERT
  TO authenticated
  WITH CHECK (user_id = (SELECT auth.uid()));

CREATE POLICY "Allow update for own payments"
  ON payments
  FOR UPDATE
  TO authenticated
  USING (user_id = (SELECT auth.uid()));

CREATE POLICY "Allow delete for own payments"
  ON payments
  FOR DELETE
  TO authenticated
  USING (user_id = (SELECT auth.uid()));

-- RLS policies for settings
CREATE POLICY "Allow read access to own settings"
  ON settings
  FOR SELECT
  TO authenticated
  USING (user_id = (SELECT auth.uid()));

CREATE POLICY "Allow insert for own settings"
  ON settings
  FOR INSERT
  TO authenticated
  WITH CHECK (user_id = (SELECT auth.uid()));

CREATE POLICY "Allow update for own settings"
  ON settings
  FOR UPDATE
  TO authenticated
  USING (user_id = (SELECT auth.uid()));

CREATE POLICY "Allow delete for own settings"
  ON settings
  FOR DELETE
  TO authenticated
  USING (user_id = (SELECT auth.uid()));

-- Insert default banks
INSERT INTO default_banks (name, code, logo_path, support_number, website, color_hex, priority)
VALUES 
('HDFC Bank', 'HDFC', 'assets/bank_icons/HDFC.svg', '1800 202 6161', 'https://www.hdfcbank.com', 'FF0066B2', 1),
('ICICI Bank', 'ICICI', 'assets/bank_icons/ICICI.svg', '1800 1080', 'https://www.icicibank.com', 'FFFF7E00', 2),
('SBI Card', 'SBI', 'assets/bank_icons/SBI.svg', '1800 1234', 'https://www.onlinesbi.com', 'FF1F5D36', 3),
('Axis Bank', 'AXIS', 'assets/bank_icons/AXIS.svg', '1800 419 5555', 'https://www.axisbank.com', 'FFE91E63', 4),
('Bank of Baroda', 'BOB', 'assets/bank_icons/BOB.svg', '1800 102 4455', 'https://www.bankofbaroda.in', 'FFE31937', 5),
('Yes Bank', 'YES', 'assets/bank_icons/YES.svg', '1800 1200', 'https://www.yesbank.in', 'FF00AEEF', 6),
('Kotak Mahindra Bank', 'KOTAK', 'assets/bank_icons/KOTAK.svg', '1860 266 2666', 'https://www.kotak.com', 'FF5D2E8E', 7),
('IndusInd Bank', 'INDUSIND', 'assets/bank_icons/INDUSIND.svg', '1860 267 7777', 'https://www.indusind.com', 'FF003366', 8),
('Standard Chartered', 'SCB', 'assets/bank_icons/SCB.svg', '1800 419 8300', 'https://www.sc.com/in', 'FF1A3E72', 9),
('RBL Bank', 'RBL', 'assets/bank_icons/RBL.svg', '1800 222 900', 'https://www.rblbank.com', 'FFE31937', 10),
('Punjab National Bank', 'PNB', 'assets/bank_icons/PNB.svg', '1800 180 2222', 'https://www.pnbindia.in', 'FFD11D2B', 11),
('Union Bank of India', 'UBI', 'assets/bank_icons/UBI.svg', '1800 222 244', 'https://www.unionbankofindia.co.in', 'FF005F9E', 12),
('HSBC', 'HSBC', 'assets/bank_icons/HSBC.svg', '1800 267 3456', 'https://www.hsbc.co.in', 'FFDB0011', 13),
('Citi Bank', 'CITI', 'assets/bank_icons/CITI.svg', '1860 210 2484', 'https://www.online.citibank.co.in', 'FF003D70', 14),
('American Express', 'AMEX', 'assets/bank_icons/AMEX.svg', '1800 419 2122', 'https://www.americanexpress.com', 'FF016FD0', 15),
('DBS Bank', 'DBS', 'assets/bank_icons/DBS.svg', '1800 209 1496', 'https://www.dbs.com/in', 'FF003D70', 16),
('IDFC First Bank', 'IDFC', 'assets/bank_icons/IDFC.svg', '1800 419 8332', 'https://www.idfcfirstbank.com', 'FFE31937', 17),
('Bank of India', 'BOI', 'assets/bank_icons/BOI.svg', '1800 220 229', 'https://www.bankofindia.co.in', 'FF0066B3', 18),
('Canara Bank', 'CANARA', 'assets/bank_icons/CANARA.svg', '1800 425 0018', 'https://canarabank.com', 'FFF7941D', 19),
('Federal Bank', 'FEDERAL', 'assets/bank_icons/FEDERAL.svg', '1800 425 1199', 'https://www.federalbank.co.in', 'FF0066B3', 21),
('Bandhan Bank', 'BANDHAN', 'assets/bank_icons/BANDHAN.svg', '1800 258 8181', 'https://www.bandhanbank.com', 'FFE31937', 22);


-- Auth Tokens
create table if not exists public.device_tokens (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id) on delete cascade,
  device_token text not null,
  platform text check (platform in ('android', 'ios')) not null,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  constraint unique_user_token unique (user_id, device_token)
);

-- Optional: Index for faster lookup
create index idx_device_tokens_user_id on public.device_tokens(user_id);

-- Enable RLS
alter table public.device_tokens enable row level security;

create policy "Allow insert for authenticated users"
on public.device_tokens
for insert
with check (
  auth.uid() = user_id
);

create policy "Allow update if user owns the token"
on public.device_tokens
for update
using (
  auth.uid() = user_id
);

create policy "Allow select only own tokens"
on public.device_tokens
for select
using (
  auth.uid() = user_id
);

create policy "Allow delete only own token"
on public.device_tokens
for delete
using (
  auth.uid() = user_id
);

create table if not exists public.notification_logs (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id),
  card_id text not null,
  title text not null,
  body text not null,
  payload text not null,
  sent_at timestamptz not null default now()
);

alter table public.notification_logs enable row level security;

-- Allow insert from service
create index idx_notification_logs_user_id on public.notification_logs(user_id);

-- Allow insert from service
create policy "Allow service inserts"
  on public.notification_logs
  for insert
  with check (auth.role() = 'service_role');

-- Allow users to select their own logs
create policy "Allow user selects"
  on public.notification_logs
  for select
  using (user_id = (select auth.uid()));