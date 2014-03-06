class Post < ActiveRecord::Base
  belongs_to :user
  has_many :comments, counter_cache: true

  def self.query_by_source source, source_id
    self.where(source: source, source_id: source_id).first
  end

end
