require 'media'
require 'recursive_open_struct'

module Media

  # It declares the configuration attributes of media related processings. In detail:
  #
  #
  # tmp_prefix:: prefix of the temporary files created by the media processings
  # avtools:: settings related to libav
  #           avprobe:: settings related to the libav tool avprobe (see <tt>man avprobe for further informations</tt>)
  #                     cmd:: settings related to the command line
  #                           sh_vars:: shell environment variables set when the related command is executed
  #                           bin:: the executable related to the command
  #                           subexec_timeout:: the command execution timeout used by Subexec (in seconds); if exceeded, the command execution will be interrupted and exit with an error
  #           avconv:: settings related to the libav tool avconv (see <tt>man avconv for further informations</tt>)
  #                    cmd:: settings related to the command line
  #                          sh_vars:: as for *avtools.avprobe.cmd.sh_vars*
  #                          bin:: as for *avtools.avprobe.cmd.bin*
  #                          timeout:: the command execution timeout used by avconv (in seconds); if exceeded, the command execution will be interrupted and exit with an error
  #                    video:: settings related to the video processing
  #                            formats:: settings related to the output video formats
  #                                      mp4:: settings related to the video mp4 format
  #                                            codecs:: the video and the audio codecs
  #                                            threads:: the encoding execution threads amount
  #                                            qa:: the audio quality
  #                                            default_bitrates:: the encoding default bitrates
  #                                      webm:: settings related to the video webm format
  #                                             codecs:: as for *avconv.video.formats.mp4.codecs*
  #                                             threads:: as for *avconv.video.formats.mp4.threads*
  #                                             qa:: as for *avconv.video.formats.mp4.qa*
  #                                             default_bitrates:: as for *avconv.video.formats.mp4.default_bitrates*
  #                            output:: settings related to the output videos
  #                                     width:: width of the output videos
  #                                     height:: height of the output videos
  #                    audio:: settings related to the audio processing
  #                            formats:: settings related to the audio output formats
  #                                      m4a:: settings related to the audio m4a format
  #                                            codecs:: as for *avconv.video.formats.mp4.codecs* (video codec is null)
  #                                            threads:: as for *avconv.video.formats.mp4.threads*
  #                                            qa:: as for *avconv.video.formats.mp4.qa*
  #                                            default_bitrates:: as for *avconv.video.formats.mp4.default_bitrates*
  #                                      ogg:: settings related to the video ogg format
  #                                            codecs:: as for *avconv.video.formats.mp4.codecs* (video codec is null)
  #                                            threads:: as for *avconv.video.formats.mp4.threads*
  #                                            qa:: as for *avconv.video.formats.mp4.qa*
  #                                            default_bitrates:: as for *avconv.video.formats.mp4.default_bitrates*
  # sox:: settings related to sox
  #       cmd:: settings related to the command line
  #             bin:: as for *avtools.avprobe.cmd.bin*
  #             global_options:: common sox options used when sox commands are launched
  # imagemagick:: settings related to imagemagick
  #               convert:: settings related to imagemagick convert
  #                         cmd:: settings related to the command line
  #                               bin:: as for *avtools.avprobe.cmd.bin*
  # video:: settings related to the output videos
  #         cover_format:: filename format of the video cover image
  #         thumb_format:: filename format of the video thumb image
  #         thumb_sizes:: video thumb image sizes
  # duration_threshold:: maximum difference of duration between the generated videos
  CONFIG = RecursiveOpenStruct.new({
    avtools: {
      avprobe: {
        cmd: {
          sh_vars: {},
          bin: 'avprobe',
          subexec_timeout: 10
        }
      },
      avconv: {
        cmd: {
          sh_vars: {},
          bin: 'avconv',
          timeout: 86400
        },
        video: {
          formats: {
            mp4: {
              codecs: %w( libx264 aac ),
              threads: 'auto',
              qa: 4,
              default_bitrates: { video: nil , audio: '200k' }
            },
            webm: { 
              codecs: %w( libvpx libvorbis ),
              threads: 4,
              qa: 5,
              default_bitrates: { video: '2M', audio: '200k' }
            }
          },
          output: {
            width: 960,
            height: 540
          }
        },
        audio: {
          formats: {
            m4a: {
              codecs: [nil, 'aac'],
              threads: 'auto',
              qa: 4,
              default_bitrates: { video: nil, audio: '200k' }
            },
            ogg: { 
              codecs: [nil, 'libvorbis'],
              threads: 4,
              qa: 5,
              default_bitrates: { video: nil, audio: '200k' }
            }
          }
        }
      }
    },
    sox: {
      cmd: {
        bin: 'sox',
        global_options: %w( -V6 --buffer 131072 --multi-threaded )
      }
    },
    imagemagick: {
      convert: {
        cmd: {
          bin: 'convert'
        }
      }
    },
    video: {
      cover_format: 'cover_%s.jpg',
      thumb_format: 'thumb_%s.jpg',
      thumb_sizes:  [200, 200]
    },
    duration_threshold: 1
  })

end