require "paper_trail/sinatra/version"

require "active_support/core_ext/object" # provides the `try` method

module PaperTrail
  # Extensions to `Sinatra`.
  module Sinatra
    # Register this module inside your Sinatra application to gain access to
    # controller-level methods used by PaperTrail.
    def self.registered(app)
      app.use RequestStore::Middleware
      app.helpers self
      app.before {
        set_paper_trail_whodunnit
        set_paper_trail_request_info
      }
    end

    protected

    # Returns the user who is responsible for any changes that occur.
    # By default this calls `current_user` and returns the result.
    #
    # Override this method in your controller to call a different
    # method, e.g. `current_person`, or anything you like.
    def user_for_paper_trail
      return unless defined?(current_user)
      ActiveSupport::VERSION::MAJOR >= 4 ? current_user.try!(:id) : current_user.try(:id)
    rescue NoMethodError
      current_user
    end

    def info_for_paper_trail
      {}
    end

    private

    # Tells PaperTrail who is responsible for any changes that occur.
    def set_paper_trail_whodunnit
      @set_paper_trail_whodunnit_called = true
      ::PaperTrail.whodunnit = user_for_paper_trail if ::PaperTrail.enabled?
    end

    def set_paper_trail_request_info
      @set_paper_trail_request_info_called = true
      ::PaperTrail.controller_info = info_for_paper_trail
    end
  end
end

if defined?(::Sinatra)
  ::Sinatra.register(::PaperTrail::Sinatra)
end
