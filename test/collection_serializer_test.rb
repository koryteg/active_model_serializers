require 'test_helper'

module ActiveModel
  class Serializer
    class CollectionSerializerTest < ActiveSupport::TestCase
      def setup
        @comment = Comment.new
        @post = Post.new
        @resource = build_named_collection @comment, @post
        @serializer = collection_serializer.new(@resource, { some: :options })
      end

      def collection_serializer
        CollectionSerializer
      end

      def build_named_collection(*resource)
        resource.define_singleton_method(:name) { 'MeResource' }
        resource
      end

      def test_has_object_reader_serializer_interface
        assert_equal @serializer.object, @resource
      end

      def test_respond_to_each
        assert_respond_to @serializer, :each
      end

      def test_each_object_should_be_serialized_with_appropriate_serializer
        serializers =  @serializer.to_a

        assert_kind_of CommentSerializer, serializers.first
        assert_kind_of Comment, serializers.first.object

        assert_kind_of PostSerializer, serializers.last
        assert_kind_of Post, serializers.last.object

        assert_equal serializers.last.custom_options[:some], :options
      end

      def test_serializer_option_not_passed_to_each_serializer
        serializers = collection_serializer.new([@post], { serializer: PostSerializer }).to_a

        refute serializers.first.custom_options.key?(:serializer)
      end

      def test_root_default
        @serializer = collection_serializer.new([@comment, @post])
        assert_equal @serializer.root, nil
      end

      def test_root
        expected =  'custom_root'
        @serializer = collection_serializer.new([@comment, @post], root: expected)
        assert_equal @serializer.root, expected
      end

      def test_root_with_no_serializers
        expected =  'custom_root'
        @serializer = collection_serializer.new([], root: expected)
        assert_equal @serializer.root, expected
      end

      def test_json_key
        assert_equal @serializer.json_key, 'comments'
      end

      def test_json_key_with_resource_with_name_and_no_serializers
        serializer = collection_serializer.new(build_named_collection)
        assert_equal serializer.json_key, 'me_resources'
      end

      def test_json_key_with_resource_with_nil_name_and_no_serializers
        resource = []
        resource.define_singleton_method(:name) { nil }
        serializer = collection_serializer.new(resource)
        assert_equal serializer.json_key, nil
      end

      def test_json_key_with_resource_without_name_and_no_serializers
        serializer = collection_serializer.new([])
        assert_equal serializer.json_key, nil
      end

      def test_json_key_with_root
        serializer = collection_serializer.new(@resource, root: 'custom_root')
        assert_equal serializer.json_key, 'custom_roots'
      end

      def test_json_key_with_root_and_no_serializers
        serializer = collection_serializer.new(build_named_collection, root: 'custom_root')
        assert_equal serializer.json_key, 'custom_roots'
      end
    end
  end
end
