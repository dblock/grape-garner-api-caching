require 'grape'
require 'mongoid'
require 'garner'
require "garner/mixins/mongoid"
require "garner/mixins/rack"
require 'active_support'

Garner.configure do |config|
  config.cache = ActiveSupport::Cache::MemoryStore.new
  config.binding_key_strategy = Garner::Strategies::Binding::Key::BindingIndex
  config.binding_invalidation_strategy = Garner::Strategies::Binding::Invalidation::BindingIndex
end

Mongoid.load! 'mongoid.yml', 'development'

class Widget
  include Mongoid::Document
  include Garner::Mixins::Mongoid::Document
end

class API < Grape::API
  helpers Garner::Mixins::Rack

  format :json

  get ':id' do
    garner.bind(Widget.identify(params[:id])) do
      Widget.find(params[:id]) || error!('Not Found', 404)
    end
  end

  delete ':id' do
    widget = Widget.find(params[:id]) || error!('Not Found', 404)
    widget.destroy
    widget
  end

  get do
    garner.bind(Widget) do
      sleep 2
      Widget.all.as_json
    end
  end

  post do
    Widget.create!
  end
end

run API
