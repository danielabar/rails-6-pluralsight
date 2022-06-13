class WikiPost < ApplicationRecord
  has_one_attached :image

  def meta
    "Created by #{author} on #{I18n.l(created_at, format: :long)} and last updated #{I18n.l(updated_at, format: :long)}."
  end
end
