# frozen_string_literal: true

class REST::TagSerializerPanko < Panko::Serializer
  include RoutingHelper

  attributes :name, :url, :following, :history

  def self.filters_for(context, scope)
    { except: [:following] } unless scope[:current_user].present?
  end

  def url
    tag_url(object)
  end

  def name
    object.display_name
  end

  def following
    if context[:relationships]
      context[:relationships].following_map[object.id] || false
    else
      TagFollow.where(tag_id: object.id, account_id: current_user.account_id).exists?
    end
  end

  def history
    object.history.as_json
  end
end
