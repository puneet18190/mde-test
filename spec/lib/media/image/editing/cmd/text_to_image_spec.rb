require 'spec_helper'


module Media
  module Image
    module Editing
      class Cmd
        describe TextToImage do
          context 'with valid arguments' do
            def output
              @output ||= Rails.root.join('tmp', 'test.jpg').to_s
            end

            def text
              @text ||= Tempfile.open(Rails.application.config.tempfiles_prefix.call) do |f|
                f.write("Test\ntest")
                f
              end
            end

            before(:all) do
              FileUtils.rm output if File.exists? output
            end

            context 'with hex colors' do
              let(:options) { { color: '#2EAADC', background_color: '#373737' } }
              it 'works' do
                expect{ described_class.new(text, output, options).run! $stdout, $stderr }.to_not raise_error
              end
            end

            context 'text colors' do
              let(:options) { { color: 'black', background_color: 'white' } }
              it 'works' do
                expect{ described_class.new(text, output, options).run! $stdout, $stderr }.to_not raise_error
              end
            end

            after(:all) do
              text.unlink
              begin
                FileUtils.rm output
              rescue Errno::ENOENT
              end
            end
            
          end
        end
      end
    end
  end
end