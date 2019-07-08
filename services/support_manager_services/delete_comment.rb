require './lib/service'
require './app/models/support_manager/ticket'
require './app/models/support_manager/comment'

module SupportManagerServices
  class DeleteCommentService < Service

    def execute
      comment = scoped_comments.find(params[:id])
      if current_user.id == comment.author_id || current_user.can_do?(:moderator)
        comment.destroy!
      else
        raise Errors::Forbidden
      end
    end

    private

    def scoped_comments
      SupportManager::Comment.where(organisation_id: current_organisation.id)
    end

  end
end
