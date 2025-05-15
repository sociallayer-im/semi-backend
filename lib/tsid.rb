module Tsid
    VERSION = '0.1.0'

    class Generator
      # Base32 sortable encoding characters
      ENCODING_CHARS = '234567abcdefghijklmnopqrstuvwxyz'.freeze
      ENCODING_CHARS_MAP = ENCODING_CHARS.chars.each_with_index.to_h.freeze

      # Constants for TSID structure
      MICROSECONDS_BITS = 53
      CLOCK_ID_BITS = 10
      TSID_LENGTH = 13

      # Initialize with a random clock ID
      def initialize(clock_id = nil)
        @clock_id = clock_id || rand(2**CLOCK_ID_BITS)
        @clock_id &= (2**CLOCK_ID_BITS - 1) # Ensure it fits in 10 bits
        @last_timestamp = 0
      end

      # Generate a new TSID
      def generate(timestamp = nil)
        timestamp_us = get_timestamp_us(timestamp)
        ensure_monotonicity(timestamp_us)

        integer = (timestamp_us << CLOCK_ID_BITS) | @clock_id
        encode(integer)
      end

      def generate_int()
        timestamp_us = get_timestamp_us()
        ensure_monotonicity(timestamp_us)

        integer = (timestamp_us << CLOCK_ID_BITS) | @clock_id
        encode(integer)
      end

      # Parse a TSID string back to its components
      def parse(tsid_str)
        integer = decode(tsid_str)
        timestamp_us = integer >> CLOCK_ID_BITS
        clock_id = integer & ((1 << CLOCK_ID_BITS) - 1)

        {
          timestamp: Time.at(timestamp_us / 1_000_000.0),
          timestamp_us: timestamp_us,
          clock_id: clock_id,
          integer: integer
        }
      end

      # Get microseconds since epoch, ensuring appropriate precision
      def get_timestamp_us(timestamp = nil)
        timestamp ||= Time.now

        # If timestamp has microsecond precision
        if timestamp.respond_to?(:tv_usec)
          (timestamp.to_i * 1_000_000) + timestamp.tv_usec
        # If timestamp only has millisecond precision, multiply by 1000 as specified
        else
          (timestamp.to_f * 1_000_000).to_i
        end
      end

      # Ensure monotonicity even if called multiple times in the same microsecond
      def ensure_monotonicity(timestamp_us)
        if timestamp_us <= @last_timestamp
          timestamp_us = @last_timestamp + 1
        end
        @last_timestamp = timestamp_us
        timestamp_us
      end

      # Encode an integer as a base32-sortable string
      def encode(integer)
        result = ''
        remaining = integer

        # Always encode to 13 characters
        TSID_LENGTH.times do
          result = ENCODING_CHARS[remaining % 32] + result
          remaining /= 32
        end

        result
      end

      # Decode a base32-sortable string to an integer
      def decode(tsid_str)
        raise ArgumentError, "Invalid TSID length (must be #{TSID_LENGTH})" unless tsid_str.length == TSID_LENGTH

        integer = 0
        tsid_str.each_char do |char|
          value = ENCODING_CHARS_MAP[char]
          raise ArgumentError, "Invalid character in TSID: #{char}" if value.nil?

          integer = (integer * 32) + value
        end

        integer
      end
    end
  end
