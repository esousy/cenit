module Setup
  class Translation < Setup::Task
    include Setup::TranslationCommon

    BuildInDataType.regist(self)

    Setup::Models.exclude_actions_for self, :new, :edit, :translator_update, :import, :convert, :delete_all

    protected

    def translate_export(message)
      if (result = translator.run(object_ids: object_ids_from(message), source_data_type: data_type_from(message), task: self)) &&
        Cenit::Utility.json_object?(result)
        file_name = "#{data_type.title.collectionize}_#{DateTime.now.strftime('%Y-%m-%d_%Hh%Mm%S')}"
        file_name += ".#{translator.file_extension}" if translator.file_extension.present?
        notify(type: :notice,
               message: "'#{translator.custom_title}' export result",
               attachment: {
                 filename: file_name,
                 contentType: translator.mime_type || 'application/octet-stream',
                 body: case result
                       when Hash, Array
                         JSON.pretty_generate(result)
                       else
                         result.to_s
                       end
               })
      end
    end

    def translate_update(message)
      simple_translate(message)
    end

    def translate_conversion(message)
      simple_translate(message)
    end

    def simple_translate(message)
      if translator.source_handler
        translator.run(object_ids: object_ids_from(message), task: self)
      else
        objects = objects_from(message)
        objects_count = objects.count
        processed = 0.0
        objects.each do |object|
          translator.run(object: object, task: self, data_type: data_type_from(message))
          processed += 1
          self.progress = processed / objects_count * 100
          save
        end
      end
    end
  end
end
