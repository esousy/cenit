module Setup
  class Push < Setup::Task
    include Setup::DataUploader
    include HashField

    build_in_data_type

    belongs_to :source_collection, class_name: Setup::Collection.to_s, inverse_of: nil
    belongs_to :shared_collection, class_name: Setup::CrossSharedCollection.to_s, inverse_of: nil

    before_save do
      self.source_collection = Setup::Collection.where(id: message[:source_collection_id]).first if source_collection.blank?
      self.shared_collection = Setup::CrossSharedCollection.where(id: message[:shared_collection_id]).first if shared_collection.blank?
    end

    def run(message)
      if (source_collection = Setup::Collection.where(id: (source_collection_id = message[:source_collection_id])).first)
        if (shared_collection = Setup::CrossSharedCollection.where(id: (shared_collection_id = message[:shared_collection_id])).first)
          fail "Can not pull up on an installed shared collection #{shared_collection.versioned_name}" if shared_collection.installed?
          begin
            shared_collection.readme = source_collection.readme
            shared_collection.data = source_collection.collecting_data
            fail shared_collection.errors.full_messages.to_sentence unless shared_collection.save
          rescue ::Exception => ex
            fail "Error updating shared collection #{shared_collection.versioned_name} (#{ex.message})"
          end
        else
          fail "Shared Collection with id #{shared_collection_id} not found"
        end
      else
        fail "Collection with id #{source_collection_id} not found"
      end
    end
  end
end