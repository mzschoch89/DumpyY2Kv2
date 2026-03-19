#!/usr/bin/env python3
"""
Composite real screenshots into angled phone mockups on AI backgrounds
"""

from PIL import Image, ImageDraw, ImageFilter
import math
import os

def create_phone_frame(screenshot_path, angle_degrees=12, phone_width=900):
    """Create a phone mockup with screenshot at an angle"""
    
    # Load screenshot
    screenshot = Image.open(screenshot_path).convert('RGBA')
    
    # Phone proportions (iPhone-like)
    bezel = 14
    corner_radius = 50
    screen_corner_radius = 40
    
    # Calculate phone dimensions based on screenshot aspect ratio
    screen_width = phone_width - (bezel * 2)
    screen_height = int(screen_width * (screenshot.height / screenshot.width))
    phone_height = screen_height + (bezel * 2)
    
    # Resize screenshot
    screenshot = screenshot.resize((screen_width, screen_height), Image.LANCZOS)
    
    # Create phone body (black with rounded corners)
    phone = Image.new('RGBA', (phone_width, phone_height), (0, 0, 0, 0))
    phone_draw = ImageDraw.Draw(phone)
    
    # Draw phone body
    phone_draw.rounded_rectangle(
        [0, 0, phone_width, phone_height],
        radius=corner_radius,
        fill=(25, 25, 25, 255)
    )
    
    # Create rounded mask for screen
    screen_mask = Image.new('L', (screen_width, screen_height), 0)
    mask_draw = ImageDraw.Draw(screen_mask)
    mask_draw.rounded_rectangle(
        [0, 0, screen_width, screen_height],
        radius=screen_corner_radius,
        fill=255
    )
    
    # Paste screenshot into phone
    phone.paste(screenshot, (bezel, bezel), screen_mask)
    
    # Rotate phone
    # Expand canvas to fit rotated image
    angle_rad = math.radians(abs(angle_degrees))
    new_width = int(phone_width * math.cos(angle_rad) + phone_height * math.sin(angle_rad))
    new_height = int(phone_width * math.sin(angle_rad) + phone_height * math.cos(angle_rad))
    
    rotated = phone.rotate(angle_degrees, expand=True, resample=Image.BICUBIC)
    
    return rotated

def add_shadow(image, offset=(20, 20), blur_radius=30, opacity=100):
    """Add drop shadow to image"""
    # Create shadow
    shadow = Image.new('RGBA', 
        (image.width + abs(offset[0]) + blur_radius * 2, 
         image.height + abs(offset[1]) + blur_radius * 2), 
        (0, 0, 0, 0))
    
    # Get alpha channel of image for shadow shape
    if image.mode == 'RGBA':
        alpha = image.split()[3]
    else:
        alpha = Image.new('L', image.size, 255)
    
    shadow_shape = Image.new('RGBA', image.size, (0, 0, 0, opacity))
    shadow_shape.putalpha(alpha)
    
    # Paste shadow shape offset
    shadow.paste(shadow_shape, (blur_radius + max(0, offset[0]), blur_radius + max(0, offset[1])))
    
    # Blur shadow
    shadow = shadow.filter(ImageFilter.GaussianBlur(blur_radius))
    
    # Paste original on top
    result = Image.new('RGBA', shadow.size, (0, 0, 0, 0))
    result.paste(shadow, (0, 0))
    result.paste(image, (blur_radius + max(0, -offset[0]), blur_radius + max(0, -offset[1])), image)
    
    return result

def composite_on_background(phone_with_shadow, background_path, output_path, 
                            position='center-right', y_offset=200):
    """Composite phone onto background"""
    
    bg = Image.open(background_path).convert('RGBA')
    
    # Resize background to App Store dimensions
    target_w, target_h = 1290, 2796
    bg = bg.resize((target_w, target_h), Image.LANCZOS)
    
    # Scale phone to fit nicely
    max_phone_width = int(target_w * 0.85)
    if phone_with_shadow.width > max_phone_width:
        scale = max_phone_width / phone_with_shadow.width
        new_size = (int(phone_with_shadow.width * scale), int(phone_with_shadow.height * scale))
        phone_with_shadow = phone_with_shadow.resize(new_size, Image.LANCZOS)
    
    # Position phone
    if position == 'center-right':
        x = (target_w - phone_with_shadow.width) // 2 + 50
    elif position == 'center':
        x = (target_w - phone_with_shadow.width) // 2
    else:
        x = 50
    
    y = target_h - phone_with_shadow.height - y_offset
    
    # Composite
    bg.paste(phone_with_shadow, (x, y), phone_with_shadow)
    
    # Convert to RGB for saving
    bg = bg.convert('RGB')
    bg.save(output_path, 'PNG', quality=95)
    print(f"Saved: {output_path}")

def main():
    base_dir = os.path.expanduser('~/projects/DumpyY2Kv2/appstore-screenshots')
    raw_dir = os.path.join(base_dir, 'raw')
    styled_dir = os.path.join(base_dir, 'styled')
    
    # Map: (screenshot, background, output, angle)
    configs = [
        ('02-home.png', 'v3-01-home.png', 'final-01-home.png', 12),
        ('03-workout.png', 'v3-02-workout.png', 'final-02-workout.png', -10),
        ('04-form-tips.png', 'v3-03-tips.png', 'final-03-tips.png', 8),
        ('05-programs.png', 'v3-04-program.png', 'final-04-program.png', -12),
        ('06-phase-details.png', 'v3-05-progression.png', 'final-05-progression.png', 10),
        ('07-progress.png', 'v3-06-progress.png', 'final-06-progress.png', -8),
    ]
    
    for screenshot, bg, output, angle in configs:
        screenshot_path = os.path.join(raw_dir, screenshot)
        bg_path = os.path.join(styled_dir, bg)
        output_path = os.path.join(styled_dir, output)
        
        if not os.path.exists(screenshot_path):
            print(f"Missing screenshot: {screenshot_path}")
            continue
        if not os.path.exists(bg_path):
            print(f"Missing background: {bg_path}")
            continue
            
        print(f"Processing: {screenshot} + {bg}")
        
        # Create angled phone with screenshot
        phone = create_phone_frame(screenshot_path, angle_degrees=angle, phone_width=950)
        
        # Add shadow
        phone_shadow = add_shadow(phone, offset=(25, 35), blur_radius=40, opacity=80)
        
        # Composite on background
        composite_on_background(phone_shadow, bg_path, output_path)

if __name__ == '__main__':
    main()
