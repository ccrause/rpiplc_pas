unit i2c;

interface

type
  TI2CBus = (i2c_0, i2c_1);

  { TI2cMaster }

  TI2cMaster = class
    constructor Create;
    destructor Destroy; override;
    function Initialize(i2cPort: TI2CBus): boolean;
    function ReadByteFromReg(i2caddress, regAddress: byte; out data: byte): boolean; overload;
    function ReadByteFromReg(i2caddress: byte; regAddress: uint16; out data: byte): boolean; overload;
    function ReadBytesFromReg(i2caddress, regAddress: byte; data: PByte; size: byte): boolean; overload;
    function ReadBytesFromReg(i2caddress: byte; regAddress: uint16; data: PByte; size: byte): boolean; overload;
    function WriteByteToReg(i2caddress, regAddress: byte; const data: byte): boolean; overload;
    function WriteByteToReg(i2caddress: byte; regAddress: uint16; const data: byte): boolean; overload;
    function WriteBytesToReg(i2caddress, regAddress: byte; data: PByte; size: byte
      ): boolean; overload;
    function WriteBytesToReg(i2caddress: byte; regAddress: uint16; data: PByte; size: byte
      ): boolean; overload;

    function WriteBytes(address: byte; const data: PByte; size: byte): boolean;
    function ReadBytes(address: byte; data: PByte; size: byte): boolean;
    // Check if there is an ACK when prompting the address
    function CheckAddress(address: byte): boolean;
  private
    Fi2cHandle: integer;
   end;

implementation

uses
  BaseUnix, SysUtils;


{ i2c-dev.h
/dev/i2c-X ioctl commands.  The ioctl's parameter is always an
 * unsigned long, except for:
 *	- I2C_FUNCS, takes pointer to an unsigned long
 *	- I2C_RDWR, takes pointer to struct i2c_rdwr_ioctl_data
 *	- I2C_SMBUS, takes pointer to struct i2c_smbus_ioctl_data
}

const
  I2C_RETRIES = $0701; // number of times a device address should be polled when not acknowledging */
  I2C_TIMEOUT = $0702; // set timeout in units of 10 ms */

{ NOTE: Slave address is 7 or 10 bits, but 10-bit addresses
 * are NOT supported! (due to code brokenness)
 }
  I2C_SLAVE       = $0703; // Use this slave address */
  I2C_SLAVE_FORCE = $0706; // Use this slave address, even if it is already in use by a driver! */
  I2C_TENBIT      = $0704; // 0 for 7 bit addrs, != 0 for 10 bit */
  I2C_FUNCS       = $0705; // Get the adapter functionality mask */
  I2C_RDWR        = $0707; // Combined R/W transfer (one STOP only) */
  I2C_PEC         = $0708; // != 0 to use PEC with SMBus */
  I2C_SMBUS       = $0720; // SMBus transfer */

  I2C_RDWR_IOCTL_MAX_MSGS = 42;

  // Flags for Ti2c_msg.flags field
  I2C_M_RD              = $0001; // guaranteed to be = $0001! */
  I2C_M_TEN             = $0010; // use only if I2C_FUNC_10BIT_ADDR */
  I2C_M_DMA_SAFE        = $0200; // use only in kernel space */
  I2C_M_RECV_LEN        = $0400; // use only if I2C_FUNC_SMBUS_READ_BLOCK_DATA */
  I2C_M_NO_RD_ACK       = $0800; // use only if I2C_FUNC_PROTOCOL_MANGLING */
  I2C_M_IGNORE_NAK      = $1000; // use only if I2C_FUNC_PROTOCOL_MANGLING */
  I2C_M_REV_DIR_ADDR    = $2000; // use only if I2C_FUNC_PROTOCOL_MANGLING */
  I2C_M_NOSTART	        = $4000; // use only if I2C_FUNC_NOSTART */
  I2C_M_STOP            = $8000; // use only if I2C_FUNC_PROTOCOL_MANGLING */

type
  Ti2c_msg = record
    addr: uint16;
    flags: uint16;
    len: uint16;
    buf: PByte;
  end;
  Pi2c_msg = ^Ti2c_msg;

  Ti2c_rdwr_ioctl_data = record
    msgs: Pi2c_msg;   // ptr to array of simple messages */
    nmsgs: integer;   // number of messages to exchange */
  end;

{ TI2cMaster }

constructor TI2cMaster.Create;
begin
  Fi2cHandle := -1;
end;

destructor TI2cMaster.Destroy;
begin
  if Fi2cHandle <> -1 then
    FpClose(Fi2cHandle);
end;

function TI2cMaster.Initialize(i2cPort: TI2CBus): boolean;
var
  devicePath: string[12] = '/dev/i2c-';
begin
  devicePath := devicePath + IntToStr(ord(i2cport));
  Fi2cHandle := FpOpen(devicePath, O_RDWR);
  Result := Fi2cHandle >= 0;
end;

function TI2cMaster.ReadByteFromReg(i2caddress, regAddress: byte; out
  data: byte): boolean;
var
  msgs: array[0..1] of Ti2c_msg;
  ioctl_data: Ti2c_rdwr_ioctl_data;
begin
  msgs[0].addr := i2caddress;
  msgs[0].flags := 0;
  msgs[0].len := 1;
  msgs[0].buf := @regAddress;

  msgs[1].addr := i2caddress;
  msgs[1].flags := I2C_M_RD or I2C_M_NOSTART;
  msgs[1].len := 1;
  msgs[1].buf := @data;

  ioctl_data.msgs := @msgs;
  ioctl_data.nmsgs := 2;

  if (FpIOCtl(Fi2cHandle, I2C_RDWR, @ioctl_data) < 0) then
  begin
    writeln('i2c_read error');
    Result := false;
  end
  else
    Result := true;
end;

function TI2cMaster.ReadByteFromReg(i2caddress: byte; regAddress: uint16; out
  data: byte): boolean;
var
  msgs: array[0..1] of Ti2c_msg;
  ioctl_data: Ti2c_rdwr_ioctl_data;
  buf: array[0..1] of byte;
begin
  buf[0] := hi(regAddress);
  buf[1] := lo(regAddress);
  msgs[0].addr := i2caddress;
  msgs[0].flags := 0;
  msgs[0].len := 2;
  msgs[0].buf := @buf;

  msgs[1].addr := i2caddress;
  msgs[1].flags := I2C_M_RD or I2C_M_NOSTART;
  msgs[1].len := 1;
  msgs[1].buf := @data;

  ioctl_data.msgs := @msgs;
  ioctl_data.nmsgs := 2;

  if (FpIOCtl(Fi2cHandle, I2C_RDWR, @ioctl_data) < 0) then
  begin
    writeln('i2c_read error');
    Result := false;
  end
  else
    Result := true;
end;

function TI2cMaster.ReadBytesFromReg(i2caddress, regAddress: byte; data: PByte;
  size: byte): boolean;
var
  msgs: array[0..1] of Ti2c_msg;
  ioctl_data: Ti2c_rdwr_ioctl_data;
begin
  msgs[0].addr := i2caddress;
  msgs[0].flags := 0;
  msgs[0].len := 1;
  msgs[0].buf := @regAddress;

  msgs[1].addr := i2caddress;
  msgs[1].flags := I2C_M_RD or I2C_M_NOSTART;
  msgs[1].len := size;
  msgs[1].buf := data;

  ioctl_data.msgs := @msgs;
  ioctl_data.nmsgs := 2;

  if (FpIOCtl(Fi2cHandle, I2C_RDWR, @ioctl_data) < 0) then
  begin
    writeln('i2c_read error');
    Result := false;
  end
  else
    Result := true;
end;

function TI2cMaster.ReadBytesFromReg(i2caddress: byte; regAddress: uint16;
  data: PByte; size: byte): boolean;
var
  msgs: array[0..1] of Ti2c_msg;
  ioctl_data: Ti2c_rdwr_ioctl_data;
  buf: array[0..1] of byte;
begin
  buf[0] := hi(regAddress);
  buf[1] := lo(regAddress);
  msgs[0].addr := i2caddress;
  msgs[0].flags := 0;
  msgs[0].len := 2;
  msgs[0].buf := @buf;

  msgs[1].addr := i2caddress;
  msgs[1].flags := I2C_M_RD or I2C_M_NOSTART;
  msgs[1].len := size;
  msgs[1].buf := data;

  ioctl_data.msgs := @msgs;
  ioctl_data.nmsgs := 2;

  if (FpIOCtl(Fi2cHandle, I2C_RDWR, @ioctl_data) < 0) then
  begin
    writeln('i2c_read error');
    Result := false;
  end
  else
    Result := true;
end;

function TI2cMaster.WriteByteToReg(i2caddress, regAddress: byte;
  const data: byte): boolean;
var
  msg: Ti2c_msg;
  ioctl_data: Ti2c_rdwr_ioctl_data;
  buf: array[0..1] of byte;
begin
  buf[0] := regAddress;
  buf[1] := data;
  msg.addr := i2caddress;
  msg.flags := 0;
  msg.len := 2;
  msg.buf := @buf;

  ioctl_data.msgs := @msg;
  ioctl_data.nmsgs := 1;

  if (FpIOCtl(Fi2cHandle, I2C_RDWR, @ioctl_data) < 0) then
  begin
    writeln('i2c_write error');
    Result := false;
  end
  else
    Result := true;
end;

function TI2cMaster.WriteByteToReg(i2caddress: byte; regAddress: uint16;
  const data: byte): boolean;
var
  msg: Ti2c_msg;
  ioctl_data: Ti2c_rdwr_ioctl_data;
  buf: array[0..2] of byte;
begin
  buf[0] := hi(regAddress);
  buf[1] := lo(regAddress);
  buf[2] := data;
  msg.addr := i2caddress;
  msg.flags := 0;
  msg.len := 3;
  msg.buf := @buf;

  ioctl_data.msgs := @msg;
  ioctl_data.nmsgs := 1;

  if (FpIOCtl(Fi2cHandle, I2C_RDWR, @ioctl_data) < 0) then
  begin
    writeln('i2c_write error');
    Result := false;
  end
  else
    Result := true;
end;

function TI2cMaster.WriteBytesToReg(i2caddress, regAddress: byte; data: PByte;
  size: byte): boolean;
var
  tmpData: TBytes;
  i: integer;
begin
  // Combine register address and data into one buffer
  SetLength(tmpData, size + 1);
  tmpData[0] := regAddress;
  for i := 0 to size-1 do
    tmpData[i+1] := data[i];
  Result := WriteBytes(i2caddress, @tmpData[0], Length(tmpData));
end;

function TI2cMaster.WriteBytesToReg(i2caddress: byte; regAddress: uint16;
  data: PByte; size: byte): boolean;
var
  tmpData: TBytes;
  i: integer;
begin
  // Combine register address and data into one buffer
  SetLength(tmpData, size + 2);
  tmpData[0] := hi(regAddress);
  tmpData[1] := lo(regAddress);
  for i := 0 to size-1 do
    tmpData[i+2] := data[i];
  Result := WriteBytes(i2caddress, @tmpData[0], Length(tmpData));
end;

function TI2cMaster.WriteBytes(address: byte; const data: PByte;
  size: byte): boolean;
var
  msg: Ti2c_msg;
  ioctl_data: Ti2c_rdwr_ioctl_data;
begin
  msg.addr := address;
  msg.flags := 0;
  msg.len := size;
  msg.buf := data;

  ioctl_data.msgs := @msg;
  ioctl_data.nmsgs := 1;

  if (FpIOCtl(Fi2cHandle, I2C_RDWR, @ioctl_data) < 0) then
  begin
    writeln('i2c_write error');
    Result := false;
  end
  else
    Result := true;
end;

function TI2cMaster.CheckAddress(address: byte): boolean;
var
  msg: Ti2c_msg;
  ioctl_data: Ti2c_rdwr_ioctl_data;
begin
  msg.addr := address;
  msg.flags := 0;
  msg.len := 0;
  msg.buf := nil;

  ioctl_data.msgs := @msg;
  ioctl_data.nmsgs := 1;

  Result := FpIOCtl(Fi2cHandle, I2C_RDWR, @ioctl_data) >= 0;
end;

function TI2cMaster.ReadBytes(address: byte; data: PByte; size: byte): boolean;
var
  msg: Ti2c_msg;
  ioctl_data: Ti2c_rdwr_ioctl_data;
begin
  msg.addr := address;
  msg.flags := I2C_M_RD;
  msg.len := size;
  msg.buf := data;

  ioctl_data.msgs := @msg;
  ioctl_data.nmsgs := 1;

  if (FpIOCtl(Fi2cHandle, I2C_RDWR, @ioctl_data) < 0) then
  begin
    writeln('i2c_read error');
    Result := false;
  end
  else
    Result := true;
end;

end.

