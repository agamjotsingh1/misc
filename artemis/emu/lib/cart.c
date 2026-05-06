#include <stdio.h>
#include <stdlib.h>

#include <cart.h>
#include <mem.h>
#include <logger.h>

static cart_ctx_t cart_ctx;

static const char *CART_TYPE_MAP[] = {
    [0x00] = "ROM ONLY",
    [0x01] = "MBC1",
    [0x02] = "MBC1+RAM",
    [0x03] = "MBC1+RAM+BATTERY",
    [0x05] = "MBC2",
    [0x06] = "MBC2+BATTERY",
    [0x08] = "ROM+RAM",
    [0x09] = "ROM+RAM+BATTERY",
    [0x0B] = "MMM01",
    [0x0C] = "MMM01+RAM",
    [0x0D] = "MMM01+RAM+BATTERY",
    [0x0F] = "MBC3+TIMER+BATTERY",
    [0x10] = "MBC3+TIMER+RAM+BATTERY",
    [0x11] = "MBC3",
    [0x12] = "MBC3+RAM",
    [0x13] = "MBC3+RAM+BATTERY",
    [0x19] = "MBC5",
    [0x1A] = "MBC5+RAM",
    [0x1B] = "MBC5+RAM+BATTERY",
    [0x1C] = "MBC5+RUMBLE",
    [0x1D] = "MBC5+RUMBLE+RAM",
    [0x1E] = "MBC5+RUMBLE+RAM+BATTERY",
    [0x20] = "MBC6",
    [0x22] = "MBC7+SENSOR+RUMBLE+RAM+BATTERY",
    [0xFC] = "POCKET CAMERA",
    [0xFD] = "BANDAI TAMA5",
    [0xFE] = "HuC3",
    [0xFF] = "HuC1+RAM+BATTERY",
};

static const char *CART_LIC_CODE_MAP[] = {
    [0x00] = "None",
    [0x01] = "Nintendo R&D1",
    [0x08] = "Capcom",
    [0x13] = "Electronic Arts",
    [0x18] = "Hudson Soft",
    [0x19] = "b-ai",
    [0x20] = "kss",
    [0x22] = "pow",
    [0x24] = "PCM Complete",
    [0x25] = "san-x",
    [0x28] = "Kemco Japan",
    [0x29] = "seta",
    [0x30] = "Viacom",
    [0x31] = "Nintendo",
    [0x32] = "Bandai",
    [0x33] = "Ocean/Acclaim",
    [0x34] = "Konami",
    [0x35] = "Hector",
    [0x37] = "Taito",
    [0x38] = "Hudson",
    [0x39] = "Banpresto",
    [0x41] = "Ubi Soft",
    [0x42] = "Atlus",
    [0x44] = "Malibu",
    [0x46] = "angel",
    [0x47] = "Bullet-Proof",
    [0x49] = "irem",
    [0x50] = "Absolute",
    [0x51] = "Acclaim",
    [0x52] = "Activision",
    [0x53] = "American sammy",
    [0x54] = "Konami",
    [0x55] = "Hi tech entertainment",
    [0x56] = "LJN",
    [0x57] = "Matchbox",
    [0x58] = "Mattel",
    [0x59] = "Milton Bradley",
    [0x60] = "Titus",
    [0x61] = "Virgin",
    [0x64] = "LucasArts",
    [0x67] = "Ocean",
    [0x69] = "Electronic Arts",
    [0x70] = "Infogrames",
    [0x71] = "Interplay",
    [0x72] = "Broderbund",
    [0x73] = "sculptured",
    [0x75] = "sci",
    [0x78] = "THQ",
    [0x79] = "Accolade",
    [0x80] = "misawa",
    [0x83] = "lozc",
    [0x86] = "Tokuma Shoten Intermedia",
    [0x87] = "Tsukuda Original",
    [0x91] = "Chunsoft",
    [0x92] = "Video system",
    [0x93] = "Ocean/Acclaim",
    [0x95] = "Varie",
    [0x96] = "Yonezawa/s’pal",
    [0x97] = "Kaneko",
    [0x99] = "Pack in soft",
    [0xA4] = "Konami (Yu-Gi-Oh!)"
};

cart_header_t *cart_load_header(){
    return (cart_header_t *)(cart_ctx.data + CART_HEADER_OFFSET);
}

byte verify_checksum(){
    byte checksum = 0;

    for (dblbyte address = 0x0134; address <= 0x014C; address++) {
        checksum = checksum - cart_ctx.data[address] - 1;
    }

    return (checksum & 0xFF);
}

void cart_load(char cart_filename[CART_FILENAME_SIZE]){
    snprintf(cart_ctx.filename, CART_FILENAME_SIZE, "%s", cart_filename);

    FILE* cart = fopen(cart_ctx.filename, "rb");

    if (cart == NULL) {
        ERROR("Failed to open cartridge...");
    }

    // get cart size
    fseek(cart, 0L, SEEK_END);
    cart_ctx.size = ftell(cart);
    fseek(cart, 0L, SEEK_SET);

    // read cart data
    cart_ctx.data = (byte*) malloc(sizeof(byte) * cart_ctx.size);

    fread(cart_ctx.data, cart_ctx.size, 1, cart);
    fclose(cart);

    // extract the header
    cart_ctx.header = cart_load_header();
    cart_ctx.header->title[15] = '\0';

    LOG("Cartridge Loaded:");
    LOG("\t Title    : %s", cart_ctx.header->title);
    LOG("\t Type     : %2.2X (%s)", cart_ctx.header->type, CART_TYPE_MAP[cart_ctx.header->type]);
    LOG("\t ROM Size : %d KB", 32 << cart_ctx.header->rom_size);
    LOG("\t RAM Size : %2.2X", cart_ctx.header->ram_size);
    LOG("\t LIC Code : %2.2X (%s)", cart_ctx.header->licensee, CART_LIC_CODE_MAP[cart_ctx.header->licensee]);
    LOG("\t ROM Vers : %2.2X", cart_ctx.header->version);
    LOG("\t Checksum : %2.2X (%s)", cart_ctx.header->checksum, verify_checksum() ? "PASSED" : "FAILED");

    if(!verify_checksum()) {
        ERROR("Cartridge checksum failed, cartridge may be corrupted!");
    }

    // write the cart data into virtual unified memory
    mem_write_chunk(0x0000, cart_ctx.size, cart_ctx.data);
}