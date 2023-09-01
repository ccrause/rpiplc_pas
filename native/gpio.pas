unit gpio;

{$mode ObjFPC}{$H+}

interface

 // <linux/gpio.h> - userspace ABI for the GPIO character devices

const
  GPIO_MAX_NAME_SIZE = 32;
  GPIO_V2_LINES_MAX = 64;

  GPIO_V2_LINE_NUM_ATTRS_MAX = 10;

type
  Tgpiochip_info = record
    name: array[0..GPIO_MAX_NAME_SIZE-1] of char;
    &label: array[0..GPIO_MAX_NAME_SIZE-1] of char;
    lines: uint32;
  end;

  Tgpio_v2_line_flag = (
    GPIO_V2_LINE_FLAG_USED                  = 1 shl 0,
    GPIO_V2_LINE_FLAG_ACTIVE_LOW            = 1 shl 1,
    GPIO_V2_LINE_FLAG_INPUT                 = 1 shl 2,
    GPIO_V2_LINE_FLAG_OUTPUT                = 1 shl 3,
    GPIO_V2_LINE_FLAG_EDGE_RISING           = 1 shl 4,
    GPIO_V2_LINE_FLAG_EDGE_FALLING          = 1 shl 5,
    GPIO_V2_LINE_FLAG_OPEN_DRAIN            = 1 shl 6,
    GPIO_V2_LINE_FLAG_OPEN_SOURCE           = 1 shl 7,
    GPIO_V2_LINE_FLAG_BIAS_PULL_UP          = 1 shl 8,
    GPIO_V2_LINE_FLAG_BIAS_PULL_DOWN        = 1 shl 9,
    GPIO_V2_LINE_FLAG_BIAS_DISABLED         = 1 shl 10,
    GPIO_V2_LINE_FLAG_EVENT_CLOCK_REALTIME  = 1 shl 11,
    GPIO_V2_LINE_FLAG_EVENT_CLOCK_HTE       = 1 shl 12);

  {$push}{$packrecords 8}
  Tgpio_v2_line_values = record
    bits: uint64;
    mask: uint64;
  end;
  {$pop}

  Tgpio_v2_line_attr_id = (
    GPIO_V2_LINE_ATTR_ID_FLAGS          = 1,
    GPIO_V2_LINE_ATTR_ID_OUTPUT_VALUES  = 2,
    GPIO_V2_LINE_ATTR_ID_DEBOUNCE       = 3);

  Tgpio_v2_line_attribute = record
    id: uint32;
    padding: uint32;
    case integer of
      0: (flags: uint64);
      1: (values: uint64);
      2: (debounce_period_us: uint32);
  end;

  {$push}{$packrecords 8}
  Tgpio_v2_line_config_attribute = record
    attr: Tgpio_v2_line_attribute;
    mask: uint64;
  end;

  Tgpio_v2_line_config = record
    flags: uint64;
    num_attrs: uint32;
    padding: array[0..4] of uint32;
    attrs: array[0..GPIO_V2_LINE_NUM_ATTRS_MAX-1] of Tgpio_v2_line_config_attribute;
  end;
  {$pop}

  Tgpio_v2_line_request = record
    offsets: array[0..GPIO_V2_LINES_MAX-1] of uint32;
    consumer: array[0..GPIO_MAX_NAME_SIZE-1] of char;
    config: Tgpio_v2_line_config;
    num_lines: uint32;
    event_buffer_size: uint32;
    padding: array[0..4] of uint32;
    fd: int32;
  end;

  Tgpio_v2_line_info = record
    name: array[0..GPIO_MAX_NAME_SIZE-1] of char;
    consumer: array[0..GPIO_MAX_NAME_SIZE-1] of char;
    offset: uint32;
    num_attrs: uint32;
    flags: uint64;
    attrs: array[0..GPIO_V2_LINE_NUM_ATTRS_MAX-1] of Tgpio_v2_line_attribute;
    padding: array[0..3] of uint32;
  end;

  Tgpio_v2_line_changed_type = (
    GPIO_V2_LINE_CHANGED_REQUESTED  = 1,
    GPIO_V2_LINE_CHANGED_RELEASED   = 2,
    GPIO_V2_LINE_CHANGED_CONFIG	    = 3);

  Tgpio_v2_line_info_changed = record
    info: Tgpio_v2_line_info;
    timestamp_ns: uint64;
    event_type: uint32;
    //* Pad struct to 64-bit boundary and reserve space for future use. */
    padding: array[0..4] of uint32;
  end;

  Tgpio_v2_line_event_id = (
    GPIO_V2_LINE_EVENT_RISING_EDGE	= 1,
    GPIO_V2_LINE_EVENT_FALLING_EDGE	= 2);

  Tgpio_v2_line_event = record
    timestamp_ns: uint64;
    id: uint32;
    offset: uint32;
    seqno: uint32;
    line_seqno: uint32;
    //* Space reserved for future use. */
    padding: array[0..5] of uint32;
  end;

 { ABI v1

  This version of the ABI is deprecated.
  Use the latest version of the ABI, defined above, instead. }

const
  GPIOLINE_FLAG_KERNEL          = 1 shl 0;
  GPIOLINE_FLAG_IS_OUT          = 1 shl 1;
  GPIOLINE_FLAG_ACTIVE_LOW      = 1 shl 2;
  GPIOLINE_FLAG_OPEN_DRAIN      = 1 shl 3;
  GPIOLINE_FLAG_OPEN_SOURCE     = 1 shl 4;
  GPIOLINE_FLAG_BIAS_PULL_UP    = 1 shl 5;
  GPIOLINE_FLAG_BIAS_PULL_DOWN  = 1 shl 6;
  GPIOLINE_FLAG_BIAS_DISABLE    = 1 shl 7;

type
  Tgpioline_info = record
    line_offset: uint32;
    flags: uint32;
    name: array[0..GPIO_MAX_NAME_SIZE-1] of char;
    consumer: array[0..GPIO_MAX_NAME_SIZE-1] of char;
  end;

const
  GPIOHANDLES_MAX = 64;

  GPIOLINE_CHANGED_REQUESTED = 1;
  GPIOLINE_CHANGED_RELEASED  = 2;
  GPIOLINE_CHANGED_CONFIG    = 3;

type
  Tgpioline_info_changed = record
    info: Tgpioline_info;
    timestamp: uint64;
    event_type: uint32;
    padding: array[0..4] of uint32;
  end;

const
  GPIOHANDLE_REQUEST_INPUT          = 1 shl 0;
  GPIOHANDLE_REQUEST_OUTPUT         = 1 shl 1;
  GPIOHANDLE_REQUEST_ACTIVE_LOW     = 1 shl 2;
  GPIOHANDLE_REQUEST_OPEN_DRAIN     = 1 shl 3;
  GPIOHANDLE_REQUEST_OPEN_SOURCE    = 1 shl 4;
  GPIOHANDLE_REQUEST_BIAS_PULL_UP   = 1 shl 5;
  GPIOHANDLE_REQUEST_BIAS_PULL_DOWN = 1 shl 6;
  GPIOHANDLE_REQUEST_BIAS_DISABLE   = 1 shl 7;

type
  Tgpiohandle_request = record
    lineoffsets: array[0..GPIOHANDLES_MAX-1] of uint32;
    flags: uint32;
    default_values: array[0..GPIOHANDLES_MAX-1] of byte;
    consumer_label: array[0..GPIO_MAX_NAME_SIZE-1] of char;
    lines: uint32;
    fd: integer;
  end;

  Tgpiohandle_config = record
    flags: uint32;
    default_values: array[0..GPIOHANDLES_MAX-1] of byte;
    padding: array[0..3] of uint32;
  end;

  Tgpiohandle_data = record
    values: array[0..GPIOHANDLES_MAX-1] of byte;
  end;

const
  GPIOEVENT_REQUEST_RISING_EDGE   = 1 shl 0;
  GPIOEVENT_REQUEST_FALLING_EDGE  = 1 shl 1;
  GPIOEVENT_REQUEST_BOTH_EDGES    = GPIOEVENT_REQUEST_RISING_EDGE or GPIOEVENT_REQUEST_FALLING_EDGE;

type
  Tgpioevent_request = record
    lineoffset: uint32;
    handleflags: uint32;
    eventflags: uint32;
    consumer_label: array[0..GPIO_MAX_NAME_SIZE-1] of char;
    fd: integer;
  end;

const
  GPIOEVENT_EVENT_RISING_EDGE  = 1;
  GPIOEVENT_EVENT_FALLING_EDGE = 2;

type
  Tgpioevent_data = record
    timestamp: uint64;
    id: uint32;
  end;

const
  GPIO_GET_CHIPINFO_IOCTL          = (2 shl 30) or $B401 or ((sizeof(Tgpiochip_info) shl 16));
  GPIO_GET_LINEINFO_IOCTL          = (3 shl 30) or $B402 or ((sizeof(Tgpioline_info) shl 16));

  GPIO_V2_GET_LINEINFO_IOCTL       = (3 shl 30) or $B405 or ((sizeof(Tgpio_v2_line_info) shl 16));
  GPIO_V2_GET_LINEINFO_WATCH_IOCTL = (3 shl 30) or $B406 or ((sizeof(Tgpio_v2_line_info) shl 16));
  GPIO_V2_GET_LINE_IOCTL           = (3 shl 30) or $B407 or ((sizeof(Tgpio_v2_line_request) shl 16));
  GPIO_V2_LINE_SET_CONFIG_IOCTL    = (3 shl 30) or $B40D or ((sizeof(Tgpio_v2_line_config) shl 16));
  GPIO_V2_LINE_GET_VALUES_IOCTL    = (3 shl 30) or $B40E or ((sizeof(Tgpio_v2_line_values) shl 16));
  GPIO_V2_LINE_SET_VALUES_IOCTL    = (3 shl 30) or $B40F or ((sizeof(Tgpio_v2_line_values) shl 16));

  GPIO_GET_LINEHANDLE_IOCTL        = (3 shl 30) or $B403 or ((sizeof(Tgpiohandle_request) shl 16));
  GPIO_GET_LINEEVENT_IOCTL         = (3 shl 30) or $B404 or ((sizeof(Tgpioevent_request) shl 16));
  GPIOHANDLE_GET_LINE_VALUES_IOCTL = (3 shl 30) or $B408 or ((sizeof(Tgpiohandle_data) shl 16));
  GPIOHANDLE_SET_LINE_VALUES_IOCTL = (3 shl 30) or $B409 or ((sizeof(Tgpiohandle_data) shl 16));
  GPIOHANDLE_SET_CONFIG_IOCTL      = (3 shl 30) or $B40A or ((sizeof(Tgpiohandle_config) shl 16));
  GPIO_GET_LINEINFO_WATCH_IOCTL    = (3 shl 30) or $B40B or ((sizeof(Tgpioline_info) shl 16));
  GPIO_GET_LINEINFO_UNWATCH_IOCTL  = (3 shl 30) or $B40C or ((sizeof(uint32) shl 16));

implementation

end.

