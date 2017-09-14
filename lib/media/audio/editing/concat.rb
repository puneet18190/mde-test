require 'media'
require 'media/audio'
require 'media/audio/editing'
require 'media/logging'
require 'media/in_tmp_dir'

module Media
  module Audio
    module Editing
      # Concatenate an array of audio files producing a new audio as output
      class Concat

        include Logging
        include InTmpDir

        # Filename of the output audio (m4a format)
        OUTPUT_M4A_FORMAT = '%s.m4a'
        # Filename of the output audio (ogg format)
        OUTPUT_OGG_FORMAT = '%s.ogg'
        
        # Creates a new Media::Audio::Editing::Concat instance, which can be used to concatenate various audio files.
        #
        # ### Arguments
        #
        # * *inputs*: an array with hash values containing the audio files per format
        # * *output_without_extension*: output path without extension
        # * *log_folder* _optional_: Custom log folder path
        # 
        # See {Examples}[rdoc-label:method-c-new-label-Examples] for usage examples.
        #
        # ### Examples
        #
        #  Media::Audio::Editing::Concat.new([ { ogg: 'input.ogg', m4a: 'input.m4a'}, { ogg: 'input2.ogg', m4a: 'input2.m4a'} ], '/output/without/extension').run 
        #  #=> { m4a:'/output/without/extension.m4a', ogg:'/output/without/extension.ogg' }
        #
        def initialize(inputs, output_without_extension, log_folder = nil)
          unless inputs.is_a?(Array) &&
                 inputs.present?     &&
                 inputs.all? do |input|
                   input.is_a?(Hash)                 &&
                   input.keys.sort == FORMATS.sort   &&
                   input.values.size == FORMATS.size &&
                   input.values.all?{ |v| v.is_a? String }
                 end
            raise Error.new( "inputs must be an array with at least one element and its elements must be hashes with #{FORMATS.inspect} as keys and strings as values", 
                             inputs: inputs, output_without_extension: output_without_extension )
          end
  
          unless output_without_extension.is_a?(String)
            raise Error.new('output_without_extension must be a string', output_without_extension: output_without_extension)
          end
  
          @inputs, @output_without_extension = inputs, output_without_extension
          
          if m4a_inputs.size != ogg_inputs.size
            raise Error.new('m4a_inputs and ogg_inputs must be of the same size', inputs: @inputs, output_without_extension: @output_without_extension)
          end

          @log_folder = log_folder
        end

        # Runs the concatenation processing
        def run
          # In order to check how many video pairs we have we can check m4a_inputs, because we already checked that m4a_inputs.size == ogg_inputs.size inside the initialization
          # Edge case: if there is just one inputs hash we can just copy the inputs to their respective outputs
          return copy_first_inputs_to_outputs if m4a_inputs.size == 1
          
          in_tmp_dir { Queue.run *FORMATS.map { |format| proc{ concat(format) } }, close_connection_before_execution: true }
          outputs
        end

        private
        # Concatenation processing (per format)
        def concat(format)
          create_log_folder
          Cmd::Concat.new(inputs[format], outputs[format], format).run! *logs
        end
        
        # m4a output filename
        def m4a_output
          OUTPUT_M4A_FORMAT % @output_without_extension
        end

        # ogg output filename
        def ogg_output
          OUTPUT_OGG_FORMAT % @output_without_extension
        end

        # outputs per format
        def outputs
          { m4a: m4a_output, ogg: ogg_output }
        end

        # Inputs per format
        def inputs
          @_inputs ||= Hash[ FORMATS.map{ |f| [f, @inputs.map{ |input| input[f] } ] } ]
        end

        # array of m4a inputs
        def m4a_inputs
          @inputs.map{ |input| input[:m4a] }
        end
        
        # array of the ogg inputs
        def ogg_inputs
          @inputs.map{ |input| input[:ogg] }
        end

        # Edge case management: when there is just one inputs hash we just copy the inputs to their respective outputs
        def copy_first_inputs_to_outputs
          Hash[
            @inputs.first.map do |format, input|
              output = outputs[format]
              FileUtils.cp input, output
              [format, output]
            end
          ]
        end
      end
    end
  end
end