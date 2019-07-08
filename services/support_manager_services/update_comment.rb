require './lib/service'
require './app/models/support_manager/ticket'
require './app/models/support_manager/comment'

module SupportManagerServices
  class UpdateCommentService < Service

    def execute
      params.merge!(author: current_user.email)
      comment = scoped_comments.find(params[:id])
      comment.update!(params.to_h)
      comment
    end

    private

    def scoped_comments
      SupportManager::Comment.where(
        organisation_id: current_organisation.id, 
        author_id: current_user.id
      )
    end

  end
end
