# frozen_string_literal: true

# # Create a function. Functions do specific things, classes are specific things.

# # Classes often have methods, which are functions that are associated with a particular class, and do things associated with the thing that the class is
# # but if all you want is to do something, a function is all you need.

# # Essentially, a class is a way of grouping functions (as methods) and data (as properties) into a logical unit revolving around a certain kind of thing.
# # If you don't need that grouping, there's no need to make a class.

# # Classes (or rather their instances) are for representing things.
# #   Classes are used to define the operations supported by a particular class of objects (its instances).
# #   If your application needs to keep track of people, then Person is probably a class; the instances of this class represent particular people you are tracking.
# # Dave: Classes are also good containers for SRP / High Cohesion, if you don't know if a method should be in class A or class B then it should be in AB
# # Organization: OOP defines well known and standard ways of describing and defining both data and procedure in code.
# # State: OOP helps you define and keep track of state
# # Encapsulation: With encapsulation, procedure and data are stored together.
# # Inheritance: Inheritance allows you to define data and procedure in one place (in one class)
# # Reusability: All of these reasons and others allow for greater reusability of code
# # MAINTAINABILITY Object-oriented programming methods make code more maintainable. Identifying the source of errors is easier because objects are self-contained.
# # REUSABILITY Because objects contain both data and methods that act on data, objects can be thought of as self-contained black boxes.
# # SCALABILITY Object-oriented programs are also scalable.

# # An action is made up of a bunch of steps and needs access to the context and the options
# module Factories
#   class BaseFactory
#     attr_reader :context

#     def initialize(**context)
#       @context = OpenStruct.new(context)
#     end

#     class << self
#       def instance(**context)
#         new(**context).run
#       end

#       def instance!(**context)
#         new(context).run!
#       end
#     end

#     def run
#       run!
#     rescue StandardError
#       # Do nothing
#       # Check the log
#     end

#     def run!
#       instance
#     rescue StandardError
#       raise
#     end

#     def instance
#       'you need to implement this method in your factory'
#     end
#   end
# end

# class A1
#   def sample; end
# end

# class A2
#   def sample; end
# end

# class C
#   def sample; end
# end

# class D
#   def sample; end
# end

# module Factories
#   class TenantEmailTemplateFactory < BaseFactory
#     def instance(**_context)
#       A1.new
#     end
#   end
# end

# module Ensure
#   def ensure_context_includes(*params, with_context: nil)
#     the_context = get_context(with_context)

#     params.each do |param|
#       if the_context[param].nil?
#         # Rails.logger.error("#{self.class.name}# Missing #{param} parameter in context")
#         the_context.fail!(message: 'Command failed')
#       end
#     end
#   end

#   def ensure_one(*params, with_context: nil)
#     the_context = get_context(with_context)

#     return unless params.all? { |param| the_context[param].nil? }

#     the_context.fail!(message: 'Command failed')
#   end

#   private

#   def get_context(with_context)
#     raise ArgumentError, "neither in-scope 'context' nor 'with_context' override param found" unless defined?(context) || with_context.present?

#     # Usually we get context in scope because of Interactor (commands),
#     # so let's ensure our 'override' context behaves similarly.
#     Interactor::Context.build(with_context || context)
#   end
# end

# # Test this concept, there is no real logic in the base class so not much can happen here
# RSpec.describe Factories::BaseFactory do
#   let(:instance) { described_class.instance(**context) }
#   let(:instance!) { described_class.instance!(**context) }
#   let(:context) { {} }

#   describe '#instance' do
#     subject { instance }

#     context 'when valid context data' do
#       it { is_expected.to eq('you need to implement this method in your factory') }
#     end

#     context 'when invalid context data' do
#       let(:context) { { bad: :bad } }
#       it { is_expected.to eq('you need to implement this method in your factory') }
#     end
#   end

#   describe '#instance!' do
#     subject { instance }

#     context 'when valid context data' do
#       it { is_expected.to eq('you need to implement this method in your factory') }
#     end

#     context 'when invalid context data' do
#       let(:context) { { bad: :bad } }
#       it { is_expected.to eq('you need to implement this method in your factory') }
#     end
#   end
# end

# RSpec.describe Factories::TenantEmailTemplateFactory do
#   let(:instance) { described_class.instance(**context) }
#   let(:instance!) { described_class.instance!(**context) }
#   let(:context) { {} }

#   describe '#instance' do
#     subject { instance }

#     context 'when valid context data' do
#       it { is_expected.to be_a(A1) }
#     end

#     context 'when invalid context data' do
#       let(:context) { { bad: :bad } }
#       it { is_expected.to eq('you need to implement this method in your factory') }
#     end
#   end

#   describe '#instance!' do
#     subject { instance }

#     context 'when valid context data' do
#       it { is_expected.to eq('you need to implement this method in your factory') }
#     end

#     context 'when invalid context data' do
#       let(:context) { { bad: :bad } }
#       it { is_expected.to eq('you need to implement this method in your factory') }
#     end
#   end
# end
