class IntroductionUpdater

  def initialize(user)
    @user = user
  end

  def get_summary
    summary_from_post(find_welcome_post)
  end

  def update_summary(new_value)
    post = find_welcome_post
    return unless post

    previous_value = summary_from_post(post).strip

    if previous_value != new_value
      revisor = PostRevisor.new(post)

      remaining = post.raw.split("\n")[1..-1]
      revisor.revise!(@user, raw: "#{new_value}\n#{remaining.join("\n")}")
    end
  end

protected

  def summary_from_post(post)
    return post ? post.raw.split("\n").first : nil
  end

  def find_welcome_post
    topic_id = TopicCustomField.where(name: "is_welcome_topic").where(value: "true").pluck(:topic_id)
    unless topic_id.present?
      topic_id = Topic.listable_topics.where(slug: 'welcome-to-discourse').pluck(:id)
    end

    welcome_topic = Topic.find(topic_id).first
    return nil unless welcome_topic.present?

    post = welcome_topic.posts.where(post_number: 1).first
    return nil unless post.present?

    post
  end

end
