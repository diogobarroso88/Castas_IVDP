import 'package:image_picker/image_picker.dart';

class ImageHelper{
    ImageHelper({
        ImagePicker? imagePicker,
    }) :_imagePicker = imagePicker ?? ImagePicker();


    final ImagePicker _imagePicker;

    Future<List<XFile>>pickImageGallery({
        ImageSource source = ImageSource.gallery,
        int imageQuality = 50,
        bool multiple = true,
    }) async  {
            return await _imagePicker.pickMultiImage(imageQuality: imageQuality);
    }

    Future<List<XFile>>pickImageCamera({
        ImageSource source = ImageSource.camera,
        int imageQuality = 50,
    }) async {
        final file = await _imagePicker.pickImage(
            source: source,
            imageQuality: imageQuality,

        );
        if (file != null) return [file];
        return [];
    }

}