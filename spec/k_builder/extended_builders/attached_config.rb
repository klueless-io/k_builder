# frozen_string_literal: true

# Attach configuration to the KBuilder module
module KBuilder
  module ExtendedBuilders
    # NOT COMPLETE
    # PackageGroup = Struct.new(:key, :description, :package_names)

    # # Configuration class
    # class Configuration < BaseConfiguration
    #   attach_to(self, KBuilder::BaseConfiguration, :package_json)

    #   attr_accessor :package_groups

    #   def initialize
    #     super()
    #     @package_groups = {}
    #   end

    #   def set_package_group(key, description, package_names)
    #     package_groups[key] = PackageGroup.new(key, description, package_names)
    #   end

    #   def default_package_groups
    #     set_package_group('webpack', 'Webpack V5', %w[webpack webpack-cli webpack-dev-server])
    #     set_package_group('swc', 'SWC Transpiler', %w[@swc/cli @swc/core swc-loader])
    #     set_package_group('babel', 'Babel Transpiler', %w[@babel/core @babel/cli @babel/preset-env babel-loader])
    #     set_package_group('typescript', 'Typescript', %w[typescript ts-loader])
    #   end
    # end
  end
end
