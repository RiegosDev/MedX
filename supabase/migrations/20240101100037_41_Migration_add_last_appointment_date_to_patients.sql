-- Descrição: Adiciona coluna de última consulta na tabela de pacientes
-- Versão simplificada (sem backfill) para banco novo

-- 1. Adiciona a coluna se ela não existir
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'patients' AND column_name = 'last_appointment_date') THEN
        ALTER TABLE public.patients ADD COLUMN last_appointment_date TIMESTAMPTZ;
    END IF;
END $$;

-- 2. Cria o índice para buscas rápidas
CREATE INDEX IF NOT EXISTS idx_patients_last_appointment ON public.patients(last_appointment_date);