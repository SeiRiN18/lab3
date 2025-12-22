CREATE OR REPLACE FUNCTION total_revenue_for_service(entered_service_id INT)
RETURNS NUMERIC
LANGUAGE plpgsql
AS $$
DECLARE
  total NUMERIC;
BEGIN
  SELECT COALESCE(SUM(quantity * unit_price), 0)
    INTO total
  FROM orderservices os
  WHERE os.service_id = entered_service_id;

  RETURN total;
END;
$$;

SELECT * FROM total_revenue_for_service(1);