import 'package:funds_minder/Model/expense.dart';

class SavingOpDB {
  static final _dB = {
    'Your transportation expenses were higher than average. Consider exploring alternative transportation methods.':
        Category.travel,
    'You spent a significant portion of your budget on "Foods". By reducing expenses in this category can save a considerable amount of money each month.':
        Category.food,
    'Your utilities bills are exceeding the minimum threshold. Try to be cautious on this category and take necessary steps':
        Category.utilities,
    'Your medical expenses are on top notch. Try to take care of your health and reduce cost on this category':
        Category.medical,
    'Your educational fees are hitting the minmum threshold. Try to find some good and cheap alternatives to make it cost effective':
        Category.education,
    'You are spending too much on leisure activities. Limit your leisure expenses by utilizing your time in more effective way':
        Category.leisure,
    'You are investing too much on business. Try to rewind your balance sheet and take necessary steps':
        Category.business,
    'Expenses related to your job are going too high. Try to relocate or find a way to lessen expense on this category':
        Category.job,
    'You are spending too much in "other" categories. Take a closer look and try to lessen your cost':
        Category.other,
  };
  static final _reC = {
    'Explore carpooling options with friends or colleagues who have a similar commute. Consider using public transportation for longer distances or when it\'s more cost-effective than driving.':
        Category.travel,
    'Plan your meals in advance and prepare homemade meals whenever possible. This will not only save you money but also promote healthier eating habits.':
        Category.food,
    'Energy Efficiency: Implement energy-saving practices at home, such as turning off lights and appliances when not in use, using energy-efficient light bulbs, and maintaining well-insulated windows and doors.\n\nNegotiate Bills: Contact your utility providers and negotiate better rates or discounts. Sometimes, they may have special offers for long-term customers or customers who bundle services.':
        Category.utilities,
    'Preventive Care: Focus on preventive healthcare practices to avoid costly medical bills. Regular health check-ups, maintaining a healthy lifestyle, and following medical advice can help prevent serious health issues.\n\nGeneric Medications: When prescribed by your healthcare professional, consider using generic medications instead of brand-name drugs. Generics are often more affordable and offer the same active ingredients.':
        Category.medical,
    'Online Learning: Consider enrolling in online courses or using e-books instead of purchasing physical textbooks. Online learning platforms often offer more affordable options and discounts.\n\nStudent Discounts: Take advantage of student discounts available for various services, software, and entertainment. Many companies offer discounts to students upon verification of their student status.':
        Category.education,
    'Take advantage of discounted movie tickets, coupons, or free community events for entertainment. Look for local attractions that offer reduced admission fees on certain days or times.  PLS ADD SOME MORE RECOMMENDATION ON category education, utilities, job, business, other, medical':
        Category.leisure,
    'Build professional connections and networking relationships to access potential job opportunities or business partnerships. Networking can lead to new opportunities and help reduce job search or marketing expenses.':
        Category.business,
    'Explore opportunities for remote work to save on commuting costs and related expenses. Many companies now offer remote work options, which can be more cost-effective for employees and employers alike.':
        Category.job,
    'Subscription Auditing: Regularly review your subscriptions (e.g., streaming services, software, memberships) and cancel those you no longer use or need. This can lead to significant savings over time.\n\nDIY Projects: Consider do-it-yourself (DIY) projects for home improvements or repairs instead of hiring professionals. DIY projects can save on labor costs and provide a sense of accomplishment.':
        Category.other,
  };

  static String getCategoryWiseDescription(Category cat) {
    String des = SavingOpDB._dB.entries
        .firstWhere((element) => element.value == cat)
        .key;
    return des;
  }

  static String getCategoryWiseRecommendations(Category cat) {
    String rec = SavingOpDB._reC.entries
        .firstWhere((element) => element.value == cat)
        .key;
    return rec;
  }
}
