# == Schema Information
#
# Table name: comments
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  sentence   :string(255)      not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Comment < ActiveRecord::Base
  include DangerWord
  belongs_to :user
  has_many :evaluations

  after_create do
    if self.sentence =~ /みたいな/
      errors.add(:sentence, :mitina_uniq)
    end
    self.sentence = self.sentence + "みたいな"
    self.save!
  end

  validate :check_mitina_uniq
  validate :check_danger_word

  validates :sentence, presence: true

  def self.rank
    Comment.select(:sentence).group(:sentence).size
  end

  def total_evaluation(value)
    begin
      evaluations.where(status: value).size
    rescue
      0
    end
  end

  private

  def check_mitina_uniq
    if new_record? && self.sentence =~ /みたいな/
      errors.add(:sentence, :mitina_uniq)
    end
  end

  def check_danger_word
    DangerWord.each do |word|
      if self.sentence =~ Regexp.new(word)
        errors.add(:sentence, :danger_word)
      end
    end
  end
end
