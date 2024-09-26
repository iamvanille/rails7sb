# frozen_string_literal: true

module ActiveStorage
  module Transformers
    # = Active Storage \Transformers \Transformer
    #
    # A Transformer applies a set of transformations to an image.
    #
    # The following concrete subclasses are included in Active Storage:
    #
    # * ActiveStorage::Transformers::ImageProcessingTransformer:
    #   backed by ImageProcessing, a common interface for MiniMagick and ruby-vips
    class Transformer
      attr_reader :transformations

      # Implement this method in a concrete subclass. Have it return true when given a blob from which
      # the transformer can generate a variant.
      def self.accept?(blob)
        false
      end

      def initialize(transformations)
        @transformations = transformations
      end

      # Applies the transformations to the source image in +file+, producing a target image in the
      # specified +format+. Yields an open Tempfile containing the target image. Closes and unlinks
      # the output tempfile after yielding to the given block. Returns the result of the block.
      def transform(file, format:)
        output = process(file, format: format)

        begin
          yield output
        ensure
          output.close!
        end
      end

      private
        def create_tempfile(ext: "")
          ext = ".#{ext}" unless ext.blank? || ext.start_with?(".")
          tempfile = Tempfile.new(["transformer_", ext], binmode: true)
          yield tempfile
        ensure
          tempfile&.close!
        end

        # Returns an open Tempfile containing a transformed image in the given +format+.
        # All subclasses implement this method.
        def process(file, format:) # :doc:
          raise NotImplementedError
        end
    end
  end
end