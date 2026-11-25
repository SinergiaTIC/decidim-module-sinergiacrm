# frozen_string_literal: true

module Decidim
  module Sinergiacrm
    # This is the engine that runs on the admin interface of sinergiacrm.
    class AdminEngine < ::Rails::Engine
      isolate_namespace Decidim::Sinergiacrm::Admin

      paths["db/migrate"] = nil
      paths["lib/tasks"] = nil

      def load_seed
        nil
      end
    end
  end
end
