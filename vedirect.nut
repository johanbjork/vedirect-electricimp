// Copyright (c) 2015 Johan Bjork
// This file is licensed under the MIT License
// http://opensource.org/licenses/MIT
// Class for reading Victron ve.direct compatible devices

enum state { WAIT_HEADER, IN_KEY, IN_VALUE, IN_CHECKSUM };

class VEDIRECT {
    static HEADER1 = '\r';
    static HEADER2 = '\n';
    static DELIMITER = '\t';

    _key = "";
    _value = "";
    _bytes_sum = 0;
    _state = state.WAIT_HEADER;
    _dict = {}
    
    constructor() {
        _dict.clear();
    }
    
    function ord(byte) {
        return format("%d", byte).tointeger();
    }
    
    function input(byte) {
        if (_state == state.WAIT_HEADER) {
            _bytes_sum += ord(byte);
            if (byte == HEADER1)
                _state = state.WAIT_HEADER;
            else if (byte == HEADER2)
                _state = state.IN_KEY;
            return null;
        } else if (_state == state.IN_KEY) {
            _bytes_sum += ord(byte);
            if (byte == DELIMITER) {
                if (_key == "Checksum")
                    _state = state.IN_CHECKSUM;
                else
                    _state = state.IN_VALUE;
            } else {
                _key += format("%c", byte);
            }
            return null;
        } else if (_state == state.IN_VALUE) {
            _bytes_sum += ord(byte);
            if (byte == HEADER1) {
                _state = state.WAIT_HEADER;
                _dict[_key] <- _value;
                _key = "";
                _value = "";
            } else {
                _value += format("%c", byte);
            }
            return null;
        } else if (_state == state.IN_CHECKSUM) {
            _bytes_sum += ord(byte);
            _key = "";
            _value = "";
            _state = state.WAIT_HEADER;
            if (_bytes_sum % 256 == 0) {
                _bytes_sum = 0;
                return _dict;
            } else {
                _bytes_sum = 0;
                return null;
            }
        } else {
            server.log("Assertion error, state " + _state + " unknown");
        }
    }
}
