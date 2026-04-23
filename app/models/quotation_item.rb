class QuotationItem < ApplicationRecord
  belongs_to :quotation
  belongs_to :financial_accrual
end
