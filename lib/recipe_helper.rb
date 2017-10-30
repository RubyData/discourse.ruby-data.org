module ::RecipeHelper
  class << self
    def bootstrap(context)
      @context = context
      init_node
    end

    def top_dir
      @top_dir ||= File.expand_path('../..', __FILE__)
    end

    def node
      @context.node
    end

    private

    def init_node
      { environment: 'MITAMAE_ENVIRONMENT',
        host:        'MITAMAE_HOST',
        roles:       'MITAMAE_ROLES',
      }.each do |node_key, env_key|
        node[node_key] = ENV[env_key] if ENV[env_key]
      end
    end
  end
end

class ::MItamae::RecipeContext
  def include_middleware(name)
    include_recipe File.join(top_dir, 'recipes', 'middleware', name)
  end

  def top_dir
    ::RecipeHelper.top_dir
  end
end
