module NimbusJenkinsCascHelper
  def casc_config(config)
    YAML.dump(config.to_hash.compact.sort.to_h).gsub!(%r{\!ruby\/hash:ChefUtils::Mash(.*)$}, '')
  end
end

class Hash
  def compact
    inject({}) do |new_hash, (k, v)|
      if v.is_a?(Hash)
        v = v.compact.sort.to_h
        new_hash[k] = v unless v.empty?
      else
        new_hash[k] = v unless v.nil?
      end
      new_hash
    end
  end
end
