# frozen_string_literal: true

# Global Ruby Class Template
class {{camel name}}
  attr_accessor {{#each fields}}:{{.}}{{#if @last}}{{else}}, {{/if}}{{/each}}

  def initialize({{#each fields}}{{.}}{{#if @last}}{{else}}, {{/if}}{{/each}})
    {{#each fields}}
    @{{.}} = {{.}}
    {{/each}}
  end
end