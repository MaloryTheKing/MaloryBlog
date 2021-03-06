class Post < ApplicationRecord
  acts_as_taggable # Alias for acts_as_taggable_on :tags

  list = lambda do |page, tag|
    recent_paginated(page).with_tag(tag)
  end

  extend FriendlyId
  friendly_id :title, use: :slugged

  belongs_to :author

  PER_PAGE = 6

  scope :published, (-> { where(published: true) })
  scope :most_recent, (-> { order(published_at: :desc) })
  scope :recent_paginated, (->(page) { most_recent.paginate(page: page, per_page: PER_PAGE) })
  scope :with_tag, (->(tag) { tagged_with(tag) if tag.present? })
  scope :list_for, list

  def should_generate_new_friendly_id?
    title_changed?
  end

  def display_day_published
    if published_at.present?
      "Опубликовано #{published_at.strftime('%-b %-d, %Y')}"
    else
      'Ещё не опубликовано'
    end
  end

  def display_updated_at
    "Последнее обновление #{updated_at.strftime('%-b %-d, %Y')}" if updated_at.present?
  end

  def publish
    update(published: true, published_at: Time.now)
  end

  def unpublish
    update(published: false, published_at: nil)
  end
end
