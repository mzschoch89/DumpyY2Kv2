#!/usr/bin/env python3
"""
Generate styled App Store screenshots for DumpyY2K
- Y2K gradient backgrounds (pink/purple/turquoise)
- Phone mockup frames
- Marketing headlines
- Floating sparkle decorations
"""

import os
from PIL import Image, ImageDraw, ImageFont
import math

# App Store 6.7" dimensions
FINAL_WIDTH = 1290
FINAL_HEIGHT = 2796

# Phone mockup settings
PHONE_WIDTH = 1000
PHONE_CORNER_RADIUS = 70
PHONE_BEZEL = 16
SCREEN_CORNER_RADIUS = 55

# Colors (Y2K theme)
COLORS = {
    'hot_pink': (248, 87, 166),
    'turquoise': (0, 229, 204),
    'purple': (176, 106, 179),
    'lavender': (200, 170, 220),
    'white': (255, 255, 255),
    'black': (0, 0, 0),
}

# Screenshot configs: (filename, headline, subheadline, gradient_type)
SCREENSHOTS = [
    ('02-home.png', 'BUILD YOUR', 'DREAM BOOTY', 'pink_purple'),
    ('03-workout.png', 'TRACK EVERY', 'REP & SET', 'pink_orange'),
    ('04-form-tips.png', 'PRO TIPS FOR', 'PERFECT FORM', 'teal_purple'),
    ('05-programs.png', '4-PHASE', 'GLUTE PROGRAM', 'rainbow'),
    ('06-phase-details.png', 'STRUCTURED', 'PROGRESSION', 'green_teal'),
    ('07-progress.png', 'SEE YOUR', 'GAINS GROW', 'pink_lavender'),
]

def create_gradient(width, height, gradient_type):
    """Create a gradient background"""
    img = Image.new('RGB', (width, height))
    draw = ImageDraw.Draw(img)
    
    if gradient_type == 'pink_purple':
        start = (255, 240, 235)  # Light peachy pink
        mid = (255, 220, 240)    # Soft pink
        end = (240, 230, 255)    # Light lavender
    elif gradient_type == 'pink_orange':
        start = (255, 235, 230)
        mid = (255, 225, 220)
        end = (255, 245, 235)
    elif gradient_type == 'teal_purple':
        start = (230, 255, 250)
        mid = (240, 240, 255)
        end = (255, 235, 250)
    elif gradient_type == 'rainbow':
        start = (255, 240, 235)
        mid = (240, 255, 245)
        end = (245, 235, 255)
    elif gradient_type == 'green_teal':
        start = (235, 255, 240)
        mid = (230, 255, 250)
        end = (240, 250, 255)
    elif gradient_type == 'pink_lavender':
        start = (255, 235, 245)
        mid = (250, 235, 255)
        end = (240, 240, 255)
    else:
        start = (255, 245, 240)
        mid = (255, 240, 245)
        end = (245, 240, 255)
    
    for y in range(height):
        ratio = y / height
        if ratio < 0.5:
            r = int(start[0] + (mid[0] - start[0]) * (ratio * 2))
            g = int(start[1] + (mid[1] - start[1]) * (ratio * 2))
            b = int(start[2] + (mid[2] - start[2]) * (ratio * 2))
        else:
            r = int(mid[0] + (end[0] - mid[0]) * ((ratio - 0.5) * 2))
            g = int(mid[1] + (end[1] - mid[1]) * ((ratio - 0.5) * 2))
            b = int(mid[2] + (end[2] - mid[2]) * ((ratio - 0.5) * 2))
        draw.line([(0, y), (width, y)], fill=(r, g, b))
    
    return img

def draw_sparkle(draw, x, y, size, color=(255, 255, 255, 200)):
    """Draw a 4-point sparkle"""
    # Vertical line
    draw.line([(x, y - size), (x, y + size)], fill=color, width=3)
    # Horizontal line
    draw.line([(x - size, y), (x + size, y)], fill=color, width=3)
    # Diagonal lines (smaller)
    small = int(size * 0.6)
    draw.line([(x - small, y - small), (x + small, y + small)], fill=color, width=2)
    draw.line([(x + small, y - small), (x - small, y + small)], fill=color, width=2)

def add_phone_frame(screenshot, output_size):
    """Add a phone frame around the screenshot"""
    # Create transparent image for phone
    phone_height = int(PHONE_WIDTH * (output_size[1] / output_size[0]) * 0.72)
    
    # Scale screenshot to fit inside phone
    screen_width = PHONE_WIDTH - (PHONE_BEZEL * 2)
    screen_height = int(screen_width * (screenshot.height / screenshot.width))
    
    scaled_screenshot = screenshot.resize((screen_width, screen_height), Image.LANCZOS)
    
    # Create phone frame with shadow
    phone_img = Image.new('RGBA', (PHONE_WIDTH + 40, screen_height + (PHONE_BEZEL * 2) + 40), (0, 0, 0, 0))
    
    # Draw shadow
    shadow_draw = ImageDraw.Draw(phone_img)
    shadow_draw.rounded_rectangle(
        [25, 25, PHONE_WIDTH + 25, screen_height + (PHONE_BEZEL * 2) + 25],
        radius=PHONE_CORNER_RADIUS,
        fill=(0, 0, 0, 40)
    )
    
    # Draw phone body (black bezel)
    shadow_draw.rounded_rectangle(
        [20, 20, PHONE_WIDTH + 20, screen_height + (PHONE_BEZEL * 2) + 20],
        radius=PHONE_CORNER_RADIUS,
        fill=(20, 20, 20, 255)
    )
    
    # Create mask for rounded screen
    mask = Image.new('L', (screen_width, screen_height), 0)
    mask_draw = ImageDraw.Draw(mask)
    mask_draw.rounded_rectangle([0, 0, screen_width, screen_height], radius=SCREEN_CORNER_RADIUS, fill=255)
    
    # Apply mask to screenshot
    if scaled_screenshot.mode != 'RGBA':
        scaled_screenshot = scaled_screenshot.convert('RGBA')
    
    # Paste screenshot into phone
    phone_img.paste(scaled_screenshot, (20 + PHONE_BEZEL, 20 + PHONE_BEZEL), mask)
    
    return phone_img

def create_styled_screenshot(screenshot_path, headline1, headline2, gradient_type, output_path):
    """Create a styled App Store screenshot"""
    # Load screenshot
    screenshot = Image.open(screenshot_path)
    
    # Create gradient background
    bg = create_gradient(FINAL_WIDTH, FINAL_HEIGHT, gradient_type)
    bg = bg.convert('RGBA')
    
    # Add phone with screenshot
    phone = add_phone_frame(screenshot, (FINAL_WIDTH, FINAL_HEIGHT))
    
    # Position phone (centered, lower half)
    phone_x = (FINAL_WIDTH - phone.width) // 2
    phone_y = FINAL_HEIGHT - phone.height - 80
    
    bg.paste(phone, (phone_x, phone_y), phone)
    
    # Add text
    draw = ImageDraw.Draw(bg)
    
    # Try to load a bold font
    try:
        font_large = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf", 120)
        font_accent = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf", 130)
    except:
        font_large = ImageFont.load_default()
        font_accent = font_large
    
    # Draw headline 1 (regular weight appearance)
    text1_bbox = draw.textbbox((0, 0), headline1, font=font_large)
    text1_width = text1_bbox[2] - text1_bbox[0]
    text1_x = (FINAL_WIDTH - text1_width) // 2
    text1_y = 180
    
    # Text shadow
    draw.text((text1_x + 3, text1_y + 3), headline1, font=font_large, fill=(0, 0, 0, 30))
    draw.text((text1_x, text1_y), headline1, font=font_large, fill=COLORS['hot_pink'])
    
    # Draw headline 2 (accent - turquoise)
    text2_bbox = draw.textbbox((0, 0), headline2, font=font_accent)
    text2_width = text2_bbox[2] - text2_bbox[0]
    text2_x = (FINAL_WIDTH - text2_width) // 2
    text2_y = text1_y + 130
    
    draw.text((text2_x + 3, text2_y + 3), headline2, font=font_accent, fill=(0, 0, 0, 30))
    draw.text((text2_x, text2_y), headline2, font=font_accent, fill=COLORS['turquoise'])
    
    # Add sparkles
    sparkle_positions = [
        (120, 250, 25),
        (FINAL_WIDTH - 150, 320, 20),
        (180, phone_y - 50, 18),
        (FINAL_WIDTH - 200, phone_y + 100, 22),
        (100, FINAL_HEIGHT - 300, 15),
        (FINAL_WIDTH - 120, FINAL_HEIGHT - 400, 18),
    ]
    
    for x, y, size in sparkle_positions:
        draw_sparkle(draw, x, y, size, color=COLORS['white'] + (180,))
    
    # Save
    bg = bg.convert('RGB')
    bg.save(output_path, 'PNG', quality=95)
    print(f"Created: {output_path}")

def main():
    raw_dir = os.path.expanduser('~/projects/DumpyY2Kv2/appstore-screenshots/raw')
    styled_dir = os.path.expanduser('~/projects/DumpyY2Kv2/appstore-screenshots/styled')
    
    os.makedirs(styled_dir, exist_ok=True)
    
    for i, (filename, h1, h2, gradient) in enumerate(SCREENSHOTS, 1):
        input_path = os.path.join(raw_dir, filename)
        output_path = os.path.join(styled_dir, f'{i:02d}-styled.png')
        
        if os.path.exists(input_path):
            create_styled_screenshot(input_path, h1, h2, gradient, output_path)
        else:
            print(f"Missing: {input_path}")

if __name__ == '__main__':
    main()
